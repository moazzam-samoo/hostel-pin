#!/usr/bin/env node
/**
 * FIX-7.2 — one-time backfill for `hostels` documents written before the
 * geo-query shape fix.
 *
 * Two things are wrong with pre-fix documents:
 *
 *   1. `location` was written as a bare GeoPoint with a sibling top-level
 *      `geohash`. `geoflutterfire_plus` queries `orderBy('location.geohash')`,
 *      which only matches documents where `location` is a MAP shaped
 *      `{geopoint, geohash}` (GeoFirePoint.data's shape). Flat documents can
 *      never match, so those listings never appear on the Map tab no matter
 *      where they actually are.
 *
 *   2. `createdAt` did not exist at all. Firestore drops documents that are
 *      missing the field a query orders by, so until every document has one,
 *      `orderBy('createdAt')` would silently hide the entire back catalogue.
 *
 * This script is idempotent: documents already in the new shape are skipped,
 * and `createdAt` is only written where absent. Safe to re-run.
 *
 * USAGE
 *   cd hostel_finder_app/scripts
 *   npm install firebase-admin
 *
 *   # A service-account key with Firestore write access:
 *   #   Firebase console -> Project settings -> Service accounts
 *   #   -> "Generate new private key"
 *   export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/serviceAccountKey.json
 *
 *   node migrate_hostel_location.js --dry-run   # report only, writes nothing
 *   node migrate_hostel_location.js             # apply
 *
 * Run --dry-run first and read the counts before applying.
 */

const admin = require('firebase-admin');

const DRY_RUN = process.argv.includes('--dry-run');
const PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'hostel-finder-ece09';

admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();

/**
 * Recomputes a geohash from a GeoPoint. Kept deliberately self-contained
 * rather than pulling a geohash dependency: the stored `geohash` is reused
 * whenever it exists, and this is only the fallback for documents that
 * somehow have a location but no hash.
 */
function encodeGeohash(latitude, longitude, precision = 9) {
  const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';
  let latRange = [-90, 90];
  let lonRange = [-180, 180];
  let hash = '';
  let bits = 0;
  let bitCount = 0;
  let even = true;

  while (hash.length < precision) {
    const range = even ? lonRange : latRange;
    const mid = (range[0] + range[1]) / 2;
    const value = even ? longitude : latitude;

    if (value > mid) {
      bits = (bits << 1) + 1;
      range[0] = mid;
    } else {
      bits = bits << 1;
      range[1] = mid;
    }

    even = !even;
    bitCount += 1;

    if (bitCount === 5) {
      hash += BASE32[bits];
      bits = 0;
      bitCount = 0;
    }
  }
  return hash;
}

async function main() {
  console.log(
    `${DRY_RUN ? '[DRY RUN] ' : ''}Migrating hostels in project "${PROJECT_ID}"...\n`
  );

  const snapshot = await db.collection('hostels').get();
  if (snapshot.empty) {
    console.log('No hostel documents found. Nothing to do.');
    return;
  }

  let migratedLocation = 0;
  let backfilledCreatedAt = 0;
  let alreadyCurrent = 0;
  let missingLocation = 0;

  // Firestore caps a batch at 500 writes; chunk to stay well under it.
  let batch = db.batch();
  let pending = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const update = {};

    const rawLocation = data.location;
    const isLegacyShape =
      rawLocation && typeof rawLocation.latitude === 'number';
    const isCurrentShape = rawLocation && rawLocation.geopoint;

    if (isLegacyShape) {
      const geohash =
        data.geohash ||
        encodeGeohash(rawLocation.latitude, rawLocation.longitude);

      update.location = { geopoint: rawLocation, geohash };
      // The flat sibling is now dead weight; nothing reads it after this.
      update.geohash = admin.firestore.FieldValue.delete();
      migratedLocation += 1;
    } else if (isCurrentShape) {
      alreadyCurrent += 1;
    } else {
      // Draft listings can legitimately have no pinned location yet.
      missingLocation += 1;
    }

    if (!data.createdAt) {
      // No real creation time survives anywhere, so fall back to the
      // document id — the app generates ids from millisecondsSinceEpoch.
      const idAsEpoch = Number(doc.id);
      update.createdAt = Number.isFinite(idAsEpoch)
        ? admin.firestore.Timestamp.fromMillis(idAsEpoch)
        : admin.firestore.FieldValue.serverTimestamp();
      backfilledCreatedAt += 1;
    }

    if (Object.keys(update).length === 0) continue;

    console.log(
      `  ${doc.id}: ${Object.keys(update).join(', ')}${DRY_RUN ? '' : ' -> queued'}`
    );

    if (!DRY_RUN) {
      batch.update(doc.ref, update);
      pending += 1;
      if (pending === 400) {
        await batch.commit();
        batch = db.batch();
        pending = 0;
      }
    }
  }

  if (!DRY_RUN && pending > 0) {
    await batch.commit();
  }

  console.log('\n--- summary ---');
  console.log(`documents scanned:        ${snapshot.size}`);
  console.log(`location shape migrated:  ${migratedLocation}`);
  console.log(`createdAt backfilled:     ${backfilledCreatedAt}`);
  console.log(`already current:          ${alreadyCurrent}`);
  console.log(`no location (drafts):     ${missingLocation}`);
  if (DRY_RUN) {
    console.log('\nDRY RUN — nothing was written. Re-run without --dry-run to apply.');
  } else {
    console.log('\nDone. Newly migrated listings should now appear on the Map tab.');
  }
}

main().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
