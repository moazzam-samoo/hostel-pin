# Cloud Functions — not yet deployed

These functions close **FIX-7.7** (deleting a listing orphans its Cloudinary
photos), the cleanup half of **FIX-7.8** (a multi-photo publish that fails
partway leaves uploaded assets with nothing referencing them), and Phase 8's
signed-upload infrastructure for the owner verification wizard.

They are written but **deliberately not deployed**: Cloud Functions require the
Firebase **Blaze** (pay-as-you-go) plan, which was not confirmed for
`hostel-finder-ece09`. Nothing in the app depends on `onHostelDeleted`/
`sweepCloudinaryOrphans` being live — until they are deployed, deleting a
listing leaves its photos in Cloudinary and the `cloudinary_orphans`
collection simply accumulates entries. The verification wizard's identity/
ownership document uploads (`CloudinaryService.uploadSignedDocument`) DO
depend on `getCloudinarySignature` being live — against a real device without
the emulator running, submitting step 2 or step 4 will fail with a
Functions-unavailable error until this is deployed.

## Why this cannot be done in the app

A Cloudinary `destroy` call must be signed with the **API secret**. Putting that
secret in the Flutter bundle would let anyone who unpacks the APK delete every
asset in the account — the exact risk `IMPLEMENTATION_PLAN.md` §7.E flags.
Uploads stay on the client through the unsigned preset; only deletes run here.

## What each function does

| Function | Trigger | Purpose |
|---|---|---|
| `onHostelDeleted` | `hostels/{id}` deleted | Destroys the `publicId` of every photo the listing referenced |
| `sweepCloudinaryOrphans` | Scheduled, every 24 h | Drains `cloudinary_orphans`, the queue the app writes on a partial upload failure |
| `getCloudinarySignature` | Callable | Phase 8 — signs a Cloudinary upload scoped to `folder: 'verification'`, `type: 'authenticated'`, for the verification wizard's CNIC/selfie/ownership-document uploads |
| `getVerificationDocumentUrl` | Callable | Phase 8 — resolves a signed delivery URL for a `type: authenticated` document by `public_id`; built here for Phase 9's Review screen, unused by this phase's own UI |

`sweepCloudinaryOrphans` uses Cloud Scheduler, which also requires Blaze.

## Deploying, when Blaze is enabled

```bash
# 1. Upgrade the project to Blaze in the Firebase console first.

cd hostel_finder_app/functions
npm install

# 2. Supply the Cloudinary credentials. These live in function config,
#    never in the app bundle or in git.
firebase functions:config:set \
  cloudinary.cloud_name="YOUR_CLOUD_NAME" \
  cloudinary.api_key="YOUR_API_KEY" \
  cloudinary.api_secret="YOUR_API_SECRET" \
  --project hostel-finder-ece09

# 3. Deploy.
cd ..
firebase deploy --only functions --project hostel-finder-ece09
```

`firebase.json` already points at this folder, so the deploy picks it up with no
further configuration.

## Verifying it works

1. Publish a listing with two or three photos and note their `publicId`s in the
   Firestore document.
2. Delete that listing from Owner → Listings.
3. `firebase functions:log --project hostel-finder-ece09` should show
   `destroying N asset(s)` followed by `destroy <id>: ok` per photo.
4. Confirm the assets are gone from the Cloudinary Media Library.

## Note on `functions.config()`

`functions.config()` is deprecated in the newer `firebase-functions` v6+ API in
favour of parameterised config / secrets. This code targets the v5 API, which
`package.json` pins. If you upgrade to v6+, migrate the three Cloudinary values
to `defineSecret` before deploying, or the config lookups will return
`undefined` and every destroy will fail authentication.
