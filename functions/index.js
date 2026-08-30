/**
 * FIX-7.7 / FIX-7.8 — server-side Cloudinary asset deletion.
 * Phase 8 — signed-upload infrastructure for owner verification documents
 * (getCloudinarySignature / getVerificationDocumentUrl, below).
 *
 * NONE of the four exports in this file are DEPLOYED, and per a decision
 * made 2026-08-30, two of them (getCloudinarySignature,
 * getVerificationDocumentUrl) never will be — this project stays on
 * Firebase's free Spark plan permanently (Cloud Functions require Blaze,
 * pay-as-you-go, which was explicitly rejected). Those two functions'
 * client caller has been repointed at a Cloudflare Worker instead
 * (`../cloudflare-worker/`, see its README) — same job, same signing
 * algorithm, same Cloudinary API secret (held there, not here), just a
 * different free host that doesn't need a billing plan. The two functions
 * below are left in place only as the original, documented reference
 * implementation the Worker was ported from — they are dead code from the
 * app's perspective (nothing calls them) and are not scheduled to deploy.
 *
 * onHostelDeleted/sweepCloudinaryOrphans (FIX-7.7/7.8) are a different
 * case: still real, still wanted, still blocked on Blaze specifically
 * because they're Firestore/Pub-Sub *triggers*, not client-callable
 * endpoints — a Cloudflare Worker can't subscribe to Firestore document
 * deletes or Cloud Scheduler the way a Cloud Function can. Until Blaze (or
 * an equivalent trigger-capable host) is adopted, deleting a listing still
 * orphans its Cloudinary photos (`cloudinary_orphans` simply accumulates
 * entries) — see DEPLOY.md in this folder for the deploy steps whenever
 * that changes.
 *
 * Why signing must live server-side at all: a Cloudinary `destroy`/
 * signed-upload call has to be signed with the API secret. Shipping that
 * secret in the app would let anyone who unpacks the APK delete or forge
 * uploads for every asset in the account, which is exactly the risk
 * IMPLEMENTATION_PLAN §7.E calls out. Unsigned hostel-photo uploads stay
 * on the client via the unsigned preset; deletes and verification-document
 * uploads both need a real secret-holding backend — Cloudflare Worker for
 * the latter now, this file for the former once Blaze (or an alternative)
 * is in place.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cloudinary = require('cloudinary').v2;

admin.initializeApp();

// Configure via:
//   firebase functions:config:set \
//     cloudinary.cloud_name="..." cloudinary.api_key="..." cloudinary.api_secret="..."
// The secret is never present in the client bundle.
cloudinary.config({
  cloud_name: functions.config().cloudinary?.cloud_name,
  api_key: functions.config().cloudinary?.api_key,
  api_secret: functions.config().cloudinary?.api_secret,
});

/**
 * Deletes a batch of assets, tolerating individual failures.
 * Cloudinary's destroy is idempotent — an id that is already gone returns
 * `result: 'not found'` rather than erroring, so retries are safe.
 */
async function destroyAll(publicIds) {
  const results = await Promise.allSettled(
    publicIds.map((id) => cloudinary.uploader.destroy(id, { invalidate: true }))
  );

  results.forEach((res, i) => {
    if (res.status === 'rejected') {
      functions.logger.error(`destroy failed for ${publicIds[i]}`, res.reason);
    } else {
      functions.logger.info(`destroy ${publicIds[i]}: ${res.value.result}`);
    }
  });

  return results.every((r) => r.status === 'fulfilled');
}

/**
 * When a hostel document is deleted, remove the photos it referenced.
 * This is the normal path — the client deletes the doc and this cleans up
 * behind it, so no client ever needs delete credentials.
 */
exports.onHostelDeleted = functions.firestore
  .document('hostels/{hostelId}')
  .onDelete(async (snap, context) => {
    const data = snap.data() || {};
    const publicIds = (data.photos || [])
      .map((p) => p.publicId)
      .filter((id) => typeof id === 'string' && id.length > 0);

    if (publicIds.length === 0) {
      functions.logger.info(`${context.params.hostelId}: no assets to remove`);
      return null;
    }

    functions.logger.info(
      `${context.params.hostelId}: destroying ${publicIds.length} asset(s)`
    );
    await destroyAll(publicIds);
    return null;
  });

/**
 * Sweeps the orphan queue the app writes when a multi-photo publish fails
 * partway (FIX-7.8). Those uploads reached Cloudinary but no listing
 * document references them, so nothing else would ever clean them up.
 *
 * The queue entry is deleted only when every id in it was handled, so a
 * partial failure is retried on the next sweep instead of being lost.
 */
exports.sweepCloudinaryOrphans = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async () => {
    const snapshot = await admin
      .firestore()
      .collection('cloudinary_orphans')
      .limit(100)
      .get();

    if (snapshot.empty) {
      functions.logger.info('orphan queue empty');
      return null;
    }

    for (const doc of snapshot.docs) {
      const publicIds = doc.data().publicIds || [];
      const allSucceeded = await destroyAll(publicIds);
      if (allSucceeded) {
        await doc.ref.delete();
      } else {
        functions.logger.warn(
          `${doc.id}: some destroys failed, leaving queued for retry`
        );
      }
    }
    return null;
  });

/**
 * Generates a Cloudinary signature for signed uploads.
 * Restricts uploads to folder "verification" and type "authenticated".
 */
exports.getCloudinarySignature = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to upload verification documents.'
    );
  }

  const timestamp = Math.round(new Date().getTime() / 1000);
  
  const paramsToSign = {
    timestamp: timestamp,
    folder: 'verification',
    type: 'authenticated',
  };

  const apiSecret = functions.config().cloudinary?.api_secret;
  if (!apiSecret) {
    throw new functions.https.HttpsError(
      'internal',
      'Cloudinary API secret not configured on the server.'
    );
  }

  const signature = cloudinary.utils.api_sign_request(paramsToSign, apiSecret);

  return {
    timestamp,
    signature,
    api_key: functions.config().cloudinary?.api_key,
    cloud_name: functions.config().cloudinary?.cloud_name,
    folder: 'verification',
    type: 'authenticated',
  };
});

/**
 * Returns a signed delivery URL for a type: authenticated asset.
 * Used by Phase 9's Review screen to view documents.
 *
 * Scoping decision (Phase 8 Block A.2): this phase's own UI never calls
 * this function — nothing under features/owner/verification/ resolves a
 * viewable URL for a submitted document, only uploads them (public_ids are
 * written straight to Firestore, never rendered as an image here). The only
 * check applied for now is "the caller is signed in"; deliberately deferred
 * to Phase 9 is scoping this to "the caller's own verifications/{uid} doc,
 * or an admin" — until Phase 9's isAdmin()-equivalent exists, any
 * authenticated user (including a student) who already knows another
 * owner's public_id could resolve a viewable URL for it. Accepted as an
 * explicit, recorded gap rather than a silent one: this function is inert
 * from the client's perspective in this phase (nothing calls it) and is
 * also undeployed (see the file header), so there is no live attack surface
 * yet — but the check must be tightened before or alongside Phase 9 wiring
 * this in for real.
 */
exports.getVerificationDocumentUrl = functions.https.onCall((data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to view verification documents.'
    );
  }

  const publicId = data.publicId;
  if (!publicId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The publicId parameter is required.'
    );
  }

  const url = cloudinary.url(publicId, {
    sign_url: true,
    type: 'authenticated',
    secure: true,
  });

  return { url };
});
