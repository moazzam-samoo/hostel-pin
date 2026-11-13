# Play Store Release Checklist: HostelPin

Status as of 2026-11-13, after the fix pass. Legend: **[x]** done and verified in this repo, **[ ]** needs YOU (account access, secrets, console actions, or a decision), **[~]** done in code but needs a deploy or device check.

Finding IDs (B-, S-, R-, POL-) refer to `AUDIT_REPORT.md`.

## A. Things only you can do (cannot be done from code)

### A1. Legal text: support email
- [x] Support email set to `usaidkhanchandio@gmail.com` in `tool/generate_legal.py`; the in-app Privacy Policy/Terms and `legal/*.html` were regenerated. To change it later: edit `CONFIG["SUPPORT_EMAIL"]` in that script and run `python tool/generate_legal.py`.
- [ ] Read `legal/privacy.html` once and confirm every statement is true. Especially: Cloudinary files removed within 30 days after account deletion (you must do this by hand), data retention, "under 13" wording, governing law (Pakistan). Not legal advice.

### A2. Host the legal pages on GitHub Pages (step by step)
This project has **no GitHub remote yet**, so do this once. Use a **separate small public repo** for the legal pages: GitHub Pages on a private repo needs a paid plan, and a separate repo keeps your app source, rules and worker config private.

1. On github.com click **New repository**. Name: `hostelpin-legal`. Visibility: **Public**. Do not add a README. Create.
2. In a terminal:
   ```
   cd "d:\Hostel Finder\hostel_finder_app\legal"
   git init -b main
   git add .
   git commit -m "Add privacy policy, terms and account deletion pages"
   git remote add origin https://github.com/<your-username>/hostelpin-legal.git
   git push -u origin main
   ```
   (`.nojekyll` is already included so the pages are served as-is.)
3. In the repo on GitHub: **Settings > Pages > Build and deployment > Source: Deploy from a branch > Branch: `main`, folder `/ (root)` > Save.**
4. After about a minute the site is live at `https://<your-username>.github.io/hostelpin-legal/`. Open and check:
   - `.../privacy.html` (use this as the **Privacy policy URL**)
   - `.../delete-account.html` (use this as the **Delete account URL**)
   - `.../terms.html`
5. Open each URL in a private/incognito window to confirm it loads without logging in.
6. Whenever you change the policy: run `python tool/generate_legal.py`, then in `legal/` run `git add . && git commit -m "Update policy" && git push`. Remember to rebuild and re-release the app too, since the in-app copy is bundled.

Optional: you can later point a custom domain at the same Pages site.

### A3. Signing (blocker)
- [ ] Create the upload keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`. Back it up in two places outside the repo.
- [ ] Create `android/key.properties` (already git-ignored):
  ```
  storeFile=C:/path/to/upload-keystore.jks
  storePassword=...
  keyAlias=upload
  keyPassword=...
  ```
  `android/app/build.gradle.kts` now reads it automatically [x]. Without the file the build falls back to the debug key and prints a warning: **never upload that bundle**.
- [ ] Enrol in **Play App Signing** when creating the app.
- [ ] Build: `flutter build appbundle --release`. Output: `build/app/outputs/bundle/release/app-release.aab`.

### A4. Firebase / Google Cloud
- [ ] Add the **SHA-1 and SHA-256** of the upload key and of the Play App Signing key (Play Console > Setup > App signing) to the Firebase Android app, download the new `google-services.json` into `android/app/`. Without this Google Sign-In fails in the release build (R-4).
- [ ] Put the Maps API key in `android/local.properties` on the build machine (`MAPS_API_KEY=...`) and restrict the key to Android package `com.hostelfinder.hostel_finder_app` + both SHA-1s (R-3).
- [ ] Restrict the Firebase API keys in Google Cloud Console (S-9).
- [ ] **Deploy the Firestore changes together with the app** (the new Home feed query needs the new index, or Home shows an error):
  `firebase deploy --only firestore:rules,firestore:indexes` [~]. Wait until the indexes show "Enabled" in the console before releasing.
- [ ] Run the rules tests (needs Java): `cd firebase-tests && npm install && firebase emulators:exec --project demo-hostel-finder-rules-test --only firestore "npm test"`. I extended `rules.test.js` but could not run it (no Java here). Fix any failure before deploying the rules.
- [ ] Redeploy the Cloudflare Worker so `/document-url` is admin-only: `cd cloudflare-worker && npx wrangler deploy` [~] (S-1). Then test: an admin can open a verification document in the admin panel; a student token gets 403.
- [ ] Create one real admin (`users/{uid}.role = 'admin'` in the console) and test approve/reject against production.

### A5. Cloudinary clean-up promise
- [ ] Account deletion removes everything in Firestore but cannot delete Cloudinary files (needs the API secret). Decide how you will honour the "30 days" promise: a monthly manual purge from the Cloudinary console, or later a Worker endpoint. Orphan queue: `cloudinary_orphans` collection.
- [ ] In Cloudinary, restrict the `hostels` and `avatars` unsigned presets (allowed formats jpg/png/webp, max size, fixed folder) (S-7).

### A6. Play Console forms (manual, cannot be automated)
- [ ] **Data safety form.** Declare collected: name, email, phone, precise location, photos, government ID images (CNIC) and selfie, user IDs, saved items; data is encrypted in transit; users can request deletion (in-app + URL). Mark ID images/selfie as collected, not shared (processed by Cloudinary/Firebase as service providers).
- [ ] **Content rating** questionnaire; **Target audience**: 18+ / not for children; **Ads**: none.
- [ ] **Permissions**: CAMERA (identity/listing photos), ACCESS_FINE/COARSE_LOCATION (nearby map, listing pin; foreground only, no background location).
- [ ] **User-generated content**: describe moderation (admin reviews every listing, report button, account suspension).
- [ ] **Store listing**: name, short and full description, 512x512 icon, 1024x500 feature graphic, 2+ phone screenshots, support email, privacy URL.
- [ ] **Testing requirement.** New personal developer accounts have had to run a closed test with a minimum number of testers for a minimum number of days before applying for production. Check Play Console > Testing > "Production access" for the current numbers and start now; it can take longer than everything else.
- [ ] Developer account identity verification (name/address/phone, and D-U-N-S for an organisation account) must be complete.

### A7. Decisions for you
- [ ] Final app name: manifest, strings and legal pages all say **HostelPin** now; Info.plist/iOS untouched. Confirm.
- [ ] `applicationId` `com.hostelfinder.hostel_finder_app` is permanent after first upload. Confirm.
- [ ] Notifications toggle (student and owner profile) is non-functional because the app has no push notifications. Hide it or leave it; Play will not reject for it.
- [ ] Four admin Settings switches (`allowNewSignups`, `autoApproveOwners`, `maintenanceMode`, `whatsappIntegration`) are written to Firestore but **nothing in the mobile app reads them**. Either wire them or remove the switches before relying on them. The admin web panel is not part of the Play release.

## B. Done in code (verified by tests/analyzer unless marked [~])

| Area | What was done |
|---|---|
| Signing | Gradle reads `android/key.properties`; release no longer hard-wired to the debug key (R-1) |
| Play: account deletion | Account Settings > Delete Account (student + owner): confirm, re-authenticate (password or Google), delete Firestore data (saved, owner listings, activities, verification, profile), delete the Auth user, return to Login. Firestore rules allow the self-delete (POL-1) |
| Play: privacy/terms | In-app Privacy Policy and Terms screens (public routes), tappable links on the Signup checkbox, rows in Account Settings and Privacy Settings, hosted HTML versions in `legal/`, generated from one source (POL-2) |
| Play: UGC policy | "Report this listing" on Hostel Detail (reason sheet, one report per user per listing, rules-validated); admin sees reports in Notifications |
| Home feed (B-1) | Newest listings first, server-side order + new composite index `status ASC, __name__ DESC` [~ deploy] |
| Auth (B-2, B-3, S-3) | Signup rolls back a half-created account; login self-heals only a brand-new account, never resurrects an admin-deleted one; `SessionService` cancels the old stream, handles errors, and signs out blocked users; login rejects blocked users |
| Owner flow (B-4, B-5, B-6, B-12) | Draft save opens Listings (was Profile); wizard back-fills `ownershipDocumentId`, and pending listings no longer demand a re-upload; rejection / "changes requested" reasons are shown in the Verification Center; no fake `mock_owner_id` |
| Validation (B-9, B-10) | Price > 0, rooms/beds >= 1 with upper bounds; email regex accepts long TLDs |
| Map (B-7, POL-4) | No permission prompt on map open; "location off" dialog opens device settings |
| Robustness (B-8, B-13, B-14, B-15, B-22) | No silent `Hyderabad` default; save without a loaded hostel no longer throws in release; detail screen safe without arguments; numeric parsing tolerant; cards safe for hostels without photos |
| Streams/cost (B-16, B-17, B-18) | Subscriptions cancelled in Saved/Detail/Profile/Map/Verification; owner notification toggle rolls back on failure; dashboard/listings no longer resubscribe on every profile change; owner activity query limited server-side |
| Back button | Pressing back on the first tab now exits the app (was a blank screen) |
| Placeholders (B-11) | Real session-only recent searches; no "Awais Khokhar"/`owner@example.com` fallbacks |
| Security rules (S-2..S-6) [~ deploy] | Profiles cannot be created verified/blocked, cannot self-change `status`; owners cannot create pre-rated/pre-viewed/featured listings or self-feature; reports validated; owner self-delete rules |
| Worker (S-1) [~ deploy] | `/document-url` is admin-only (role read from the caller's own profile via Firestore REST) |
| Admin dashboard | Added the missing `users(role, createdAt)` index the growth chart needs |
| Misc | `android:allowBackup="false"`; analyzer clean; app name consistent in permission texts |

## C. Pre-submit QA on a real phone (release build)

- [ ] Install the release `.aab` via internal testing (or `bundletool`), not a debug run.
- [ ] Fresh install > Welcome > Role Selection > Signup (student) > Home shows the **newest** listings > save/unsave > search > filter > map (allow and deny location) > detail > Call > WhatsApp > **Report this listing**.
- [ ] Signup (owner) > verification wizard (kill the app mid-way and resume) > pending > admin approves > Add tab unlocks > add listing (check draft goes to Listings) > admin approves > listing visible to students.
- [ ] Reject and "request changes" show the reason to the owner.
- [ ] **Delete account** as a student, as an email/password owner, and as a Google user. Confirm the profile and listings are gone from Firestore, and that logging in again with the same email no longer works.
- [ ] Privacy Policy and Terms open from the Signup checkbox and from Account Settings.
- [ ] Log out and log in as another account: no stale data.
- [ ] Airplane mode: cached Home loads, uploads fail with a clear message.
- [ ] 320 px wide phone, 130% font, landscape: no overflow.
- [ ] Google Sign-In (new and returning), password reset email, change password.
- [ ] Back button on both shells exits cleanly from the first tab.

## D. Release steps

1. Complete A1-A5, rebuild the `.aab`.
2. Internal testing: you plus 2-3 testers. 3. Complete A6 forms. 4. Closed test (if required), then Production with a staged rollout (e.g. 10%).
5. Add **Firebase Crashlytics** before or right after launch (not in the project yet; release crashes are otherwise invisible).

## E. Known gaps, not blocking

Search loads up to 1000 live docs (B-20); `viewCount` can be inflated (S-5); email verification not enforced (S-11); owners can edit published listings without re-review; no reviews/push notifications/dark mode; admin web panel not deployed; Worker `/signature` has no rate limit (S-7); role-selection/welcome screens use a few hardcoded text styles instead of tokens.
