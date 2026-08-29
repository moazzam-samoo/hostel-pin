/**
 * FIX-7.7 / FIX-7.8 — server-side Cloudinary asset deletion.
 *
 * NOT DEPLOYED. Cloud Functions require the Firebase Blaze (pay-as-you-go)
 * plan, which was not confirmed for this project. Until it is deployed,
 * deleting a listing still orphans its Cloudinary photos and the
 * `cloudinary_orphans` queue simply accumulates entries — nothing breaks,
 * nothing is cleaned up either. See DEPLOY.md in this folder.
 *
 * Why this must live server-side: a Cloudinary `destroy` call has to be
 * signed with the API secret. Shipping that secret in the app would let
 * anyone who unpacks the APK delete every asset in the account, which is
 * exactly the risk IMPLEMENTATION_PLAN §7.E calls out. Uploads stay on the
 * client via the unsigned preset; only deletes come through here.
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
