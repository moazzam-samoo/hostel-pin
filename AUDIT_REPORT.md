# HostelPin / Hostel Finder: Codebase Audit Report

Audit date: 2026-11-12. Read-only: no source file was changed.
Companion file: `RELEASE_CHECKLIST.md` (what to do before Play Store).

## Fix status (updated 2026-11-13)

Every finding below was addressed unless listed here as open. See `RELEASE_CHECKLIST.md` section B for the one-line description of each fix and section A for what still needs you.

- **Fixed in code:** R-1 (signing wiring), R-5, B-1..B-18, B-22, S-1 (Worker, needs `wrangler deploy`), S-2..S-4, S-6 (rules, need `firebase deploy`), POL-1 (in-app account deletion), POL-2 (privacy/terms screens + hosted pages), POL-4. Extra findings from the second pass, also fixed: back-button exit on the shells showed a blank screen; an admin-deleted user could have been silently re-created at login; admin dashboard growth chart lacked a required index; owner activity query downloaded the full history.
- **Stale in this report:** B-19 (password success screen). It already pops back to Profile; it never routed to Login. Not a bug.
- **Left open on purpose:** S-5 (view count inflation), S-7 (Worker rate limit, Cloudinary preset limits are a console task), S-8 (CORS), S-11 (email verification), B-20, B-21, POL-5/POL-6 (non-functional toggles), R-8 (confirm R8 behaviour on a device), R-9 (icon check on device).
- **New finding, open:** four admin Settings switches (`allowNewSignups`, `autoApproveOwners`, `maintenanceMode`, `whatsappIntegration`) are stored in Firestore but never read by the mobile app, so they have no effect. Wire or remove them.
- **Added by Play policy review:** a "Report this listing" feature (Play's user-generated-content policy requires an in-app way to flag content).
- **Not verifiable here:** the Firestore rules tests (no Java runtime; tests were extended but not run), anything needing a real device (Google Sign-In, Maps, camera), the live Worker, and the Play Console forms.

## 0. Scope and honesty about coverage

**Read line by line:** `main.dart`, `app.dart`, `pubspec.yaml`, Android Gradle and manifest, `firestore.rules`, `firestore.indexes.json`, the Cloudflare Worker, `InitialBinding`, `app_pages.dart`, all three middlewares, every repository except `activity_repository`/`report_repository`/`app_config_repository`, `SessionService`, `AuthService`, `CloudinaryService`, `StorageService`, `LocationService`, `Validators`, `ErrorMapper`, `UserModel`, `HostelModel` (second half), and these controllers: splash, login, signup, change-password, edit-profile, home, search, saved, map, hostel-detail, student profile, owner shell/dashboard/listings/profile, add-listing, verification wizard, admin login/users/owners/verifications.

**Skimmed or not read:** most `*_view.dart` files, the ~62 shared widgets (read through the architecture notes and test results only), admin dashboard/hostels/settings/notifications controllers, theme files, `app_strings.dart`, `functions/index.js`, `firebase-tests/`, and iOS. Treat UI-level bugs as under-audited. A second pass on views is worth doing after the blockers below are fixed.

**Tooling results:**
- `flutter analyze`: 1 info (`auth_service.dart:7`, `_injectedAuth` could be `final`). No errors or warnings.
- `flutter test`: 72 passed, 1 skipped, 2 failed. The 2 failures are golden image tests (`AppBottomNav golden`, `HostelCard .featured golden`). `AGENTS.md` already records golden mismatches as pre-existing. Not a functional signal, but regenerate or remove them before relying on CI.

## 1. Architecture as it actually works

**Stack:** Flutter 3.44.8, GetX (state, DI, routing), MVVM. Firebase Auth + Firestore, Cloudinary for images, a Cloudflare Worker for signing verification-document uploads.

**Layers (all verified in source):**
- `data/models/*`: plain Dart classes with `fromFirestore`/`toFirestore`.
- `data/repositories/*`: the only code that talks to Firestore, plus `AuthRepository` over `AuthService` (FirebaseAuth/GoogleSignIn wrapper).
- `data/services/*`: `SessionService` (permanent `Rxn<UserModel> currentUser`, fed by auth stream then `users/{uid}` stream), `CloudinaryService`, `StorageService` (compress + retry + orphan reporting), `LocationService`.
- `features/*`: View + Controller + Binding per screen. Shells (`StudentShell`, `OwnerShell`, `AdminShell`) own tab controllers.
- `shared/widgets/*`: dumb reusable widgets. `core/*`: theme tokens, strings, routes, middleware, utils.

**Boot flow:** `main` initialises Firebase and Firestore offline persistence, then `ScreenUtilInit` (375x812 on mobile), then `GetMaterialApp` with `InitialBinding` (all repos/services, all `permanent: true`). Mobile starts at Splash; web starts at the admin login (`kIsWeb`).

**Auth/navigation flow:** Splash → (signed out) Welcome → DeptWelcome → Role Selection → Login/Signup → role shell. Signed-in users go Splash → role shell by `users/{uid}.role`. Route guards: `AuthMiddleware` (Firebase user exists), `RoleMiddleware` (role matches shell), `AdminMiddleware` (role == admin).

**Data flow examples:**
- Home: `HomeController` → `HostelRepository.streamAllPublished(limit)` → `featuredHostels`/`regularHostels` → `HostelCard`. Saved state: `SavedRepository.streamSaved(uid)` → `savedHostelIds`; heart tap flips state optimistically, then `toggleSave`.
- Owner publish: `AddListingController._saveListing` → upload photos (`StorageService`, unsigned preset) → upload ownership doc (`CloudinaryService.uploadSignedDocument` → Worker `/signature` → Cloudinary) → `HostelRepository.create` (status `pending`) → activity log.
- Verification: wizard writes `verifications/{uid}` per step plus a `hostels` doc (pending). Admin approve is a 3-doc `WriteBatch`.

**Reused widgets (confirmed in use):** `HostelCard` (4 layouts, every student list), `AppBottomNav`, `FacilityGrid`/`FacilityTile`/`AmenitySelector`, `StatRowTile`, `ActivityRow`, `AppTextField`/`ValidatedTextField`, `PrimaryButton`/`SecondaryButton`, `ConfirmDialog`, `AppSnackbar`, `ImageUploadSection`, `NetworkImageBox`. Rule for UI work: extend a shared widget with a parameter instead of creating a near-duplicate, and use `AppColors`/`AppTextStyles`/`AppSpacing`/`AppStrings` tokens only.

**Deviations from the written docs (so you are not misled by `AGENTS.md`):**
- `AGENTS.md` places admin under `lib/admin/`; it is actually `lib/features/admin/`.
- `AGENTS.md` says the owner shell uses an `IndexedStack`; it actually uses a swipeable `PageView`.
- `AGENTS.md` says Owner Dashboard/AddListing/VerificationCenter still read `MockDataService`; that is stale. They now read `SessionService`.
- `AddListingGateView`: the Add tab is locked until `verificationStatus == verified` (client-side only; see S-2).

## 2. Findings

Severity: **P0** = do not publish before fixing. **P1** = fix before release if at all possible. **P2** = fix soon. **P3** = polish.

### 2.1 Release / build (P0)

| ID | Sev | Finding | Where |
|---|---|---|---|
| R-1 | P0 | Release build is signed with the **debug key** (`TODO: Add your own signing config`). Play Console rejects it. | `android/app/build.gradle.kts:53-58` |
| R-2 | P0 | No release keystore, no `key.properties`, nothing exists. Without Play App Signing enrollment you can never update the app if the key is lost. | repo-wide |
| R-3 | P0 | Google Maps key lives only in git-ignored `android/local.properties`. On any other machine or CI the build falls back to the placeholder `YOUR_GOOGLE_MAPS_API_KEY_HERE` and maps render blank. The key itself must be restricted (Android package + SHA-1) in Google Cloud. | `build.gradle.kts:24`, `local.properties` |
| R-4 | P0 | Google Sign-In will fail in the release build (`ApiException: 10`) until the **release and Play-App-Signing SHA-1/SHA-256** are added to the Firebase Android app and a fresh `google-services.json` is downloaded. | Firebase console |
| R-5 | P1 | App label is `HostelPin`; some user-facing strings say `Hostel Finder` (camera/location permission rationale, `map_controller.dart:172`, `app_strings.dart:232`). Pick one name; the Play listing name must match what users see. | manifest, `app_strings.dart`, Info.plist |
| R-6 | P1 | `applicationId = com.hostelfinder.hostel_finder_app` is permanent once uploaded. Confirm you are happy with it. | `build.gradle.kts:43` |
| R-7 | P1 | `version: 1.0.0+1` plus `local.properties` `flutter.buildMode=release/versionCode=1`. Each Play upload needs a higher versionCode. | `pubspec.yaml:4` |
| R-8 | P2 | No explicit R8/minify/obfuscation config. Verify a release APK works with whatever the Flutter default does, and keep the `--split-debug-info` symbols if you obfuscate. | Gradle |
| R-9 | P2 | `flutter_launcher_icons` and `flutter_native_splash` are dev dependencies but I did not verify they were actually run; launcher icon uses `app_logo.png` as both full and adaptive foreground, which may be clipped. Check on a real device. | `pubspec.yaml:94-99` |

### 2.2 Play Store policy blockers (P0)

| ID | Sev | Finding |
|---|---|---|
| POL-1 | P0 | **No in-app account deletion.** `AuthRepository.deleteAccount()` exists but nothing calls it (grep of `lib/`). Google Play requires in-app deletion plus a public web link for apps that let users create accounts. Admin-side delete only removes the Firestore doc, not the Auth account (rules comment `firestore.rules:89-95`). |
| POL-2 | P0 | **No privacy policy / terms.** The signup checkbox text is plain, not a link (`terms_checkbox.dart`). Settings and Privacy Settings are placeholder screens. Play requires a privacy policy URL on the listing and it should be reachable in-app. |
| POL-3 | P1 | **Data Safety form** must declare: email, name, phone, precise location, photos, government ID (CNIC) images and selfie, user IDs, Firebase/Cloudinary processing. The CNIC and selfie collection makes this a sensitive-data app; be accurate. |
| POL-4 | P1 | **Camera + location permissions:** declared correctly. Location is requested the moment the map is created (`map_controller.dart:135`), before any user action. Prefer a contextual request. |
| POL-5 | P2 | Notification toggles (student `ProfileController.notificationsEnabled`, owner `toggleNotifications`) exist, but the app has no push notifications at all. The student toggle is local-only and resets; the owner one writes a pref nothing reads. Remove or label them to avoid a "misleading UI" review comment. |
| POL-6 | P2 | The Dark Mode row shows "Coming soon". Acceptable, but consider hiding it. |

### 2.3 Security (P0 to P1)

| ID | Sev | Finding | Where |
|---|---|---|---|
| S-1 | P0 | **Worker `/document-url` has no authorization beyond "any valid Firebase user".** Any signed-in student who obtains a CNIC/selfie `public_id` can get a download URL for it. The code comments admit this ("that's Phase 9's job") but Phase 9 never added the check. Fix: have the Worker confirm the caller is an admin (Firestore REST lookup of `users/{uid}.role`, or a custom claim) or that the public_id belongs to the caller. | `cloudflare-worker/src/index.js:151-175` |
| S-2 | P1 | **Users can self-verify at signup.** `users` create rule only checks `role in [student, owner]`; it does not force `verificationStatus == 'unverified'` or `status == 'active'`. A technical user can create their own doc with `verificationStatus: 'verified'`, which unlocks the Add tab (client gate). Listings still need admin approval, so impact is limited. | `firestore.rules:62-63` |
| S-3 | P1 | **Block/unblock is cosmetic.** Admin sets `users/{uid}.status = 'blocked'`, but nothing in the app or the rules ever reads `status` for login, listing, or access. The user update rule also does not stop a blocked user from writing `status: 'active'` back to their own doc (`:73-75`). | `admin_users_controller.dart:37`, rules |
| S-4 | P1 | Owners can set `isFeatured: true` on their own listings (create and update rules do not restrict it), and can create a hostel with arbitrary `rating`, `reviewCount`, `viewCount` (only update is locked). | `firestore.rules:120-147` |
| S-5 | P2 | `viewCount` can be inflated by any signed-in user repeatedly (+1 per call, no per-user dedupe). Also `HostelDetailController` increments on every open. | `firestore.rules:154-156`, `hostel_detail_controller.dart:23` |
| S-6 | P2 | `reports` collection: any authenticated user can create arbitrary documents with no field validation. No student UI writes reports today, so this is surface area with no use. | `firestore.rules:259` |
| S-7 | P2 | Worker `/signature` has no rate limiting, size limit, or file-type limit; any signed-in user can mint unlimited signed uploads into the `verification` folder (storage-cost abuse). Cloudinary `hostels`/`avatars` presets are unsigned; restrict allowed formats, size, and folders in the preset itself. | Worker, Cloudinary console |
| S-8 | P2 | Worker CORS is `*` (fine for mobile; tighten to the admin origin if the web panel goes public). | `index.js:181-210` |
| S-9 | P2 | `firebase_options.dart` holds three public API keys. That is normal for Firebase, but each key should be restricted (Android: package + SHA; web: HTTP referrer) in Google Cloud. |
| S-10 | P2 | Admin rules and emulator tests have never been run (`AGENTS.md`: no Java in the building environment). Run `firebase emulators:exec` on `firebase-tests/rules.test.js` before trusting the admin write rules. |
| S-11 | P3 | Email-verification flow exists in `AuthRepository` but is never enforced; users can register with someone else's email. |

### 2.4 Functional bugs

| ID | Sev | Finding | Where |
|---|---|---|---|
| B-1 | P0 | **Home feed shows the oldest hostels, not the newest.** `streamAllPublished` does `.where(status==published).limit(10)` with no `orderBy`. Firestore returns documents in ascending doc-ID order (IDs are epoch milliseconds), so `limit(10)` fetches the 10 *oldest*. The client then sorts descending, which only reorders those same 10. Newly approved listings are invisible until the user scrolls to load more windows (each `loadMore` widens `limit` by 10). With more than 10 published hostels, new listings effectively never show on the first screen. Same pattern in `streamAllAdmin`, Saved's suggestions (`streamAllPublished()` default limit 10), and the admin hostel list. The `status + createdAt desc` index is already deployed; the blocker is that older docs lack `createdAt` (run `scripts/migrate_hostel_location.js` first). | `hostel_repository.dart:49-74` |
| B-2 | P1 | **Signup is not atomic.** Auth account is created first, then `createUserDoc`. If the doc write fails (offline, rules, crash), the account exists with no profile. Retrying signup says "email already in use"; logging in sends the user to Role Selection → Login → Role Selection forever, since nothing ever creates the doc. | `signup_controller.dart:50-65`, `login_controller.dart:51-53` |
| B-3 | P1 | **`SessionService` leaks stream subscriptions and has no error handler.** Each auth-state emission calls `userStream(uid).listen` without cancelling the previous listener. After logout the old listener gets permission-denied (unhandled stream error); after switching accounts two user streams are live, and the stale one can emit and overwrite `currentUser`. This is the single most central piece of state. | `session_service.dart:28-35` |
| B-4 | P1 | **Draft save sends the owner to the wrong tab.** After "Save as draft" of a new listing the code calls `onTabSelected(3)` with the comment "Switch to Listings tab", but index 3 is Profile; Listings is 1. | `add_listing_controller.dart:609` |
| B-5 | P1 | **Wizard-created hostel has no `ownershipDocumentId`.** `_completeHostelInfoStep` builds the `HostelModel` without it; step 4 stores the document only in `verifications/{uid}`. Later, when the owner opens that (still pending/draft) hostel in Edit, `_requiresOwnershipDocument` is true and `_populateForm` finds no document, so the owner must re-upload an ownership proof just to edit. | `verification_controller.dart:459-483`, `add_listing_controller.dart:167,220` |
| B-6 | P1 | **Rejected / changes-requested owners can't see why.** Admin writes `rejectionReason`; no owner screen reads it (`AGENTS.md` flags this as open). An owner hits a dead-end. |
| B-7 | P1 | **Location rationale is shown after the fact.** On the Map tab `getCurrentLocation()` fails first, then shows a "Continue?" dialog; pressing Continue just shows an error snackbar and never re-requests permission. The user can never grant it from there if they previously denied. | `map_controller.dart:138-150` |
| B-8 | P1 | **Wrong default city.** Both `HostelModel.fromFirestore` and `_extractCity`/`_fallbackCity` silently assign `Hyderabad` when no city can be derived. Listings elsewhere appear in the wrong city and wrong filter results. | `hostel_model.dart:160-165`, `add_listing_controller.dart:681-715` |
| B-9 | P1 | **Client validators accept values the server rejects.** `Validators.price` accepts 0, negatives, `1e5`; rules need `pricePerMonth > 0`. `rooms`/`beds` accept 0 and negatives. Result: a generic "Failed to save listing" error after a full photo upload (and orphaned uploads). | `validators.dart:60-88`, `firestore.rules:49` |
| B-10 | P2 | Email regex caps TLD at 4 characters, rejecting valid addresses like `name@company.online`, `.photography`. | `validators.dart:15` |
| B-11 | P2 | Fake placeholder content visible to users: Search "Recent searches" is hardcoded `['Ameerpet','Boys hostel','Under 10k']` (Ameerpet is in Hyderabad, India). `HostelCard` falls back to the owner name "Awais Khokhar" if `ownerName` is null. Owner profile shows `owner@example.com` as a fallback. | `search_controller.dart:19`, `hostel_card.dart:148,193`, `owner_profile_view.dart:36` |
| B-12 | P2 | `uid ?? 'mock_owner_id'` fallback can stamp a real listing with a fake owner id if the session is momentarily null (it then fails the `ownerId == auth.uid` rule). Fail loudly instead. | `add_listing_controller.dart:455` |
| B-13 | P2 | `toggleSave` relies on an `assert(hostel != null)` that is stripped in release; with a null hostel it throws a null-check error synchronously, outside the `catchError`, leaving the heart in the optimistic state. | `saved_repository.dart:75-76` |
| B-14 | P2 | `HostelDetailController.hostel` is `late final` and only set when `Get.arguments is HostelModel`; otherwise it calls `Get.back()` but the view still reads `controller.hostel` → `LateInitializationError` flash. Deep links / process restore will hit this. | `hostel_detail_controller.dart:13-28` |
| B-15 | P2 | One malformed hostel document (`totalRooms` stored as a double, etc.) throws inside `fromFirestore` and kills the entire Home/Search stream (shows the error state for everyone). Parse defensively (`as num?`, `.toInt()`). | `hostel_model.dart:178,208` |
| B-16 | P2 | Several `.listen()` calls are never cancelled: `SavedController` (2), `HostelDetailController`, `ProfileController`, `MapController` saved stream, `VerificationController`, all admin controllers. Each opened hostel detail leaves a live Firestore listener running (and no `onError`, so post-logout permission errors are unhandled). Cost and memory, not a crash. |
| B-17 | P2 | `OwnerProfileController.toggleNotifications` is `async void`, mutates `SessionService.currentUser` directly, and has no try/catch or rollback. A failed write leaves UI and server out of sync and throws unhandled. | `owner_profile_controller.dart:29-41` |
| B-18 | P2 | `Dashboard`/`Listings` controllers re-subscribe their Firestore streams on every `currentUser` change (any profile edit, avatar change, verification flip), causing list flicker and extra reads. | `dashboard_controller.dart:33-37` |
| B-19 | P2 | Password success screen sends a still-signed-in user to Login without signing out (known, from `AGENTS.md`). Also password change doesn't apply to Google-only accounts. |
| B-20 | P3 | Search loads up to **1000** live documents on open (`limit: 1000`), so reads scale with catalogue size on every search session. Acceptable for a small catalogue; move to server-side filtering or an index before growth. | `search_controller.dart:50` |
| B-21 | P3 | Map re-queries on every camera idle with a fixed 20 km radius regardless of zoom, and `_updateMarkers` can run concurrently (last writer wins). | `map_controller.dart:83-128` |
| B-22 | P3 | A hostel with an empty `photos` list (legacy documents) crashes cards that do `photos.first` (Home, Search, Saved, Map, carousel). Guard or default. | many files, see grep list |

### 2.5 Product / UX gaps worth knowing

- Owners can edit a published listing (price, photos, name, phone) with no re-review.
- No reviews, inquiries, or push notifications exist (documented as deferred).
- Dark mode is not implemented. Only Pakistani mobile numbers validate.
- Web admin panel has never been deployed (and has untested rules).

## 3. What looks solid

- Layering is consistent (Views are `GetView`, logic in controllers, Firestore only in repositories); naming and token discipline are consistent.
- Firestore rules are thoughtfully written (field-level `affectedKeys()` rules, no client path to publish, private `verifications`, sealed `cloudinary_orphans`).
- `flutter analyze` is clean; the non-golden test suite passes, including responsive and RTL smoke tests.
- Upload pipeline has timeouts, retries, per-file progress and orphan recording.
- Offline Firestore persistence and optimistic saves are wired.

## 4. Suggested fix order for a 3-day window

**Day 1 (blockers, mostly configuration):** R-1..R-4 (keystore, signing, SHA-1 in Firebase, Maps key restriction), POL-1 (account deletion), POL-2 (privacy policy + links), S-1 (Worker authorisation), B-1 (feed order, after running the `createdAt` backfill).
**Day 2 (correctness):** B-2, B-3, B-4, B-5, B-6, B-7, B-9, S-2, S-3, S-4 (rules + redeploy), remove fake placeholder content B-11.
**Day 3 (verification):** `flutter build appbundle --release`, install and test on a real device (including Google Sign-In and Maps), emulator rules tests (S-10), Data Safety form, internal test track upload.

Everything in P2/P3 can ship after launch unless a tester hits it.
