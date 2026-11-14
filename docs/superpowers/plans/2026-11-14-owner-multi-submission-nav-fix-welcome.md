# Owner: Up to 3 Pending Hostels, Nav Bar Fix, Welcome Name: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** (1) An unverified owner who has submitted verification can send up to 3 hostels for review before any is approved; (2) the bottom nav works while a request is in review; (3) the owner Home shows "Welcome, {name}".

**Architecture:** The "can this owner add a hostel now?" rule moves out of the shell widget into one small pure function (`OwnerAddAccess`) driven by two inputs: the owner's identity-verification doc status and their hostel count. The shell, the gate screen and `AddListingController` all use it. The nav fix is a root-cause fix, proven by a widget test first. The admin Hostels tab gains Approve/Reject, because today the only way a hostel becomes published is the identity Approve button, which publishes only the one hostel linked to the verification.

**Tech Stack:** Flutter 3.44, GetX, Cloud Firestore, fake_cloud_firestore, flutter_test.

**Spec:** the user's message of 2026-11-14 (three items below).

## What the code does today (verified)

| # | Finding | Where |
|---|---|---|
| 1 | The Add tab shows the real form only when `users/{uid}.verificationStatus == verified`; otherwise `AddListingGateView`. So a second hostel is impossible until the admin approves the first. | `features/owner/shell/owner_shell_view.dart:44-47` |
| 2 | `users.verificationStatus` is **never** `pending` for a submitted owner: owners cannot write that field (rules `firestore.rules:87`) and the submit only writes `verifications/{uid}.status = pending`. So the gate's "pending" message branch never fires. The real "submitted" signal is the **verification doc**. | `verification_controller.dart:575`, `add_listing_gate_view.dart:38` |
| 3 | Admin Approve (`approveSubmission`) publishes **only** the hostel linked as `hostelId` on the verification. There is no per-hostel approve on the admin Hostels tab (only Delete). Rules already allow an admin to change a hostel's `status` alone. | `verification_repository.dart` approve, `admin_hostels_controller.dart`, `firestore.rules:180-183` |
| 4 | Step 6 "Done" calls `Get.offAll(() => const OwnerShellView())` with **no binding**. `OwnerShellController` is a fenix lazyPut owning a `PageController` created in `onInit`. After `offAll` the old route is disposed. Likely outcome: the new shell reuses a controller whose `PageController` is disposed, so `animateToPage` fails and the tabs never change. This is a hypothesis; Task 1 proves or disproves it first. | `steps/step6_submission.dart:72`, `owner_shell_controller.dart` |
| 5 | The greeting is `Hello, {displayName} 👋` from `SessionService.currentUser.displayName`; it is blank when `displayName` is empty (e.g. some Google accounts). | `dashboard_view.dart:51-65`, `app_strings.dart:83` |

## Decisions I am making (tell me if you disagree)

1. **"Max 3" means 3 hostels in review (pending) at the same time while the owner is not yet verified.** Once the owner is verified, there is no cap (today's behavior).
2. **The first request is still the full verification wizard** (identity + first hostel). Requests 2 and 3 are only the Add Listing form (hostel + its own ownership document), because identity is already submitted. Add tab states:
   - identity not submitted (no verification doc, or `draft`) → gate screen "Complete verification first";
   - identity `pending` or `changesRequested`, fewer than 3 hostels pending → **real Add Listing form**;
   - identity `pending`, already 3 pending → gate screen "You have 3 hostels in review. Wait for a review before adding more";
   - identity `rejected` → gate screen (resubmit through Verification Center);
   - owner `verified` → real form, no cap.
3. **The cap is enforced in the app only.** Firestore rules cannot count documents, so a modified client could exceed 3. A server-side counter needs Cloud Functions, which this project cannot deploy (Spark plan). The admin sees every hostel anyway.
4. **Admin approves extra hostels from the Hostels tab** (new Approve / Reject buttons on pending rows). Approving the identity in the Verifications tab keeps publishing its linked hostel exactly as now.
5. **Welcome text:** `Welcome, {name}`; if the name is empty, fall back to the part of the email before `@`; if that is empty too, just `Welcome`.

## Global Constraints

- No hardcoded strings, colors, text styles, radii or spacing in `features/` or `shared/widgets/`; add `AppStrings` entries and use the existing tokens.
- MVVM: views have no business logic; controllers and repositories own it. Reuse `EmptyState`, `PrimaryButton`, `ConfirmDialog`, `AppSnackbar`.
- Existing hostels and owners must keep working: an already-verified owner sees no change.
- `flutter analyze` 0 issues and `flutter test` 0 failures before every commit.
- Firestore rules changes must be deployed together with the app build (Task 5 needs none, see below).

## Review Focus

- Owner with identity pending and exactly 3 hostels in review: Add tab shows the limit message, and `publishListing` also refuses (the controller check is the real guard, not only the tab).
- Owner deletes one pending hostel (count drops to 2): the Add tab opens again without an app restart.
- Admin approves the identity while the owner has 2 other pending hostels: the owner becomes verified, the cap disappears, the 2 others stay pending until approved on the Hostels tab.
- A rejected hostel does not count toward the 3; a draft does not count either (drafts are not in review).
- Owner signs out and a different owner signs in: counts and gate state come from the new uid, not the old one.
- Empty `displayName`: greeting shows the email-prefix fallback, never `Hello, `.

## File Structure

| File | Change |
|---|---|
| `lib/features/owner/shell/owner_add_access.dart` (new) | `enum OwnerAddAccess` + pure `OwnerAddAccess resolveOwnerAddAccess(...)`, `const int kMaxPendingHostels = 3` |
| `lib/features/owner/shell/owner_shell_controller.dart` | exposes `addAccess` (reactive) built from `SessionService`, the verification stream and the owner's hostel stream |
| `lib/features/owner/shell/owner_shell_view.dart` | Add tab uses `addAccess` instead of the `verified` check |
| `lib/features/owner/shell/widgets/add_listing_gate_view.dart` | three messages: not-started, limit reached, rejected |
| `lib/features/owner/add_listing/add_listing_controller.dart` | `publishListing` refuses when `addAccess` says limit reached or not allowed |
| `lib/features/owner/verification/steps/step6_submission.dart` | "Done" navigates with `Get.offAllNamed(Routes.ownerShell)` |
| `lib/features/owner/dashboard/dashboard_view.dart`, `dashboard_controller.dart` | `welcomeName` getter and the Welcome text |
| `lib/features/admin/hostels/admin_hostels_{controller,view}.dart`, `hostel_repository.dart` | Approve / Reject for pending hostels |
| `lib/core/constants/app_strings.dart` | new strings |
| `test/owner/owner_add_access_test.dart`, `test/owner/owner_shell_nav_test.dart`, `test/owner/dashboard_welcome_test.dart`, `test/admin/admin_hostels_approve_test.dart` (new) | tests |

---

### Task 1: Nav bar works while a request is in review (root cause first)

**Files:** `test/owner/owner_shell_nav_test.dart` (new); `owner_shell_controller.dart`, `step6_submission.dart` (modify).

**Interfaces:**
- Consumes: `OwnerShellView`, `OwnerShellBinding`, `Routes.ownerShell`.
- Produces: nothing new; the shell must change pages for every tab in every state.

- [ ] **Step 1: Failing test `tabs change pages after the shell is re-entered via offAll`.** Pump `GetMaterialApp` with fake Firestore and a faked `SessionService` (same pattern as `test/student/home_categories_test.dart`), signed-in owner with `verificationStatus: unverified`, a `verifications/{uid}` doc with `status: pending`. Open the shell via its route, then call `Get.offAll(() => const OwnerShellView())` (the current Done behavior), tap "Listing", "Add", "Profile", "Dashboard". Assert after each tap that the page for that tab is visible (`find.byType(ListingsView)` etc.) and `tester.takeException()` is null.
- [ ] **Step 2: Run** `flutter test test/owner/owner_shell_nav_test.dart`. Expected: FAIL. If it passes, the hypothesis in finding 4 is wrong: stop, use superpowers:systematic-debugging, and reproduce the exact user path (submit verification, press Done, tap tabs) before changing anything.
- [ ] **Step 3: Fix.** In `step6_submission.dart` replace `Get.offAll(() => const OwnerShellView())` with `Get.offAllNamed(Routes.ownerShell)` so `OwnerShellBinding` runs. Make `OwnerShellController.onTabSelected` safe: only call `animateToPage` when `pageController.hasClients`, and set `currentIndex` regardless.
- [ ] **Step 4: Add a second test `Done from the submission screen lands on a working shell`** that taps the Done button and then repeats the tab taps. Run both tests: PASS.
- [ ] **Step 5: Commit** `fix(owner): bottom nav works after submitting verification`.

### Task 2: Welcome name on the owner Home

**Files:** `dashboard_controller.dart`, `dashboard_view.dart`, `app_strings.dart`; `test/owner/dashboard_welcome_test.dart` (new).

**Interfaces:**
- Produces: `String DashboardController.welcomeName` (display name → email prefix → `''`); `AppStrings.dashboardWelcome(String name)` returning `'Welcome, $name'`, or `'Welcome'` when the name is empty.

- [ ] **Step 1: Failing tests** (unit, on the controller/string): `welcomeName returns displayName`; `welcomeName falls back to the email prefix when displayName is blank` (`'  '`, `a.b@x.com` → `a.b`); `dashboardWelcome('') == 'Welcome'`; `dashboardWelcome('Ali') == 'Welcome, Ali'`. Widget test: the dashboard header shows `Welcome, Ali`.
- [ ] **Step 2: Run:** FAIL.
- [ ] **Step 3: Implement** the getter and string; replace `AppStrings.dashboardGreeting` usage in `_buildGreetingHeader` (remove the old string only if nothing else uses it).
- [ ] **Step 4: Run:** PASS. **Step 5: Commit** `feat(owner): welcome name on dashboard`.

### Task 3: The add-access rule (pure logic)

**Files:** `lib/features/owner/shell/owner_add_access.dart` (new); `test/owner/owner_add_access_test.dart` (new).

**Interfaces:**
- Produces:
  - `const int kMaxPendingHostels = 3;`
  - `enum OwnerAddAccess { allowed, needsVerification, limitReached, rejected }`
  - `OwnerAddAccess resolveOwnerAddAccess({required VerificationStatus userStatus, required String? verificationDocStatus, required List<HostelModel> hostels})` where `verificationDocStatus` is the `verifications/{uid}.status` string or null.

- [ ] **Step 1: Failing tests** (table-driven, spec values): verified user → `allowed` (even with 5 pending); unverified + doc null → `needsVerification`; unverified + doc `draft` → `needsVerification`; unverified + doc `pending` + 0/1/2 pending hostels → `allowed`; same + 3 pending → `limitReached`; same + 2 pending + 5 drafts/rejected → `allowed` (only `pending` counts); doc `changesRequested` + 3 pending → `limitReached`; doc `rejected` or user `rejected` → `rejected`.
- [ ] **Step 2: Run:** FAIL (file missing). **Step 3: Implement** the function (no GetX, no Firebase imports). **Step 4: Run:** PASS. **Step 5: Commit** `feat(owner): add-listing access rule with 3-pending cap`.

### Task 4: Shell, gate screen and Add Listing use the rule

**Files:** `owner_shell_controller.dart`, `owner_shell_view.dart`, `add_listing_gate_view.dart`, `add_listing_controller.dart`, `app_strings.dart`; tests in `test/owner/owner_shell_nav_test.dart` (extend).

**Interfaces:**
- Consumes: `resolveOwnerAddAccess`, `VerificationRepository.streamVerification(uid)`, `HostelRepository.streamByOwner(uid)`, `SessionService.currentUser`.
- Produces: `Rx<OwnerAddAccess> OwnerShellController.addAccess`; `AppStrings.addTabLimitReachedTitle/Message`, `addTabNeedsVerificationMessage`, `addTabRejectedMessage`.

- [ ] **Step 1: Failing widget tests** (extend the shell test file): pending identity + 2 pending hostels → Add tab shows `AddListingView`; pending identity + 3 pending → gate with the limit message; unverified + no verification doc → gate "Start Verification"; after one pending hostel is deleted from fake Firestore, the Add tab switches to the form without a rebuild by the test; switching the signed-in uid resets the state (Review Focus). Add a controller test: `AddListingController.publishListing()` with `limitReached` shows the limit snackbar and writes nothing.
- [ ] **Step 2: Run:** FAIL.
- [ ] **Step 3: Implement.** `OwnerShellController` subscribes to the verification doc and the owner's hostels (cancel both in `onClose`, resubscribe only when the uid changes, same pattern as `DashboardController`) and recomputes `addAccess`. The shell's Add tab `Obx` switches on it: `allowed` → `AddListingView`, else `AddListingGateView(access: ...)`. The gate view chooses title/message by access and keeps the button to Verification Center (for `limitReached` the button goes to the Listings tab instead). `AddListingController.publishListing()` and the draft→pending path check `addAccess` and refuse with `AppStrings.addTabLimitReachedMessage`.
- [ ] **Step 4: Run** `flutter test test/owner`. Expected: PASS. **Step 5: Commit** `feat(owner): up to 3 hostels in review before verification`.

### Task 5: Admin approves or rejects (with a reason) extra pending hostels

**Files:** `hostel_model.dart`, `hostel_repository.dart`, `admin_hostels_controller.dart`, `admin_hostels_view.dart`, `app_strings.dart`, `firestore.rules`, `firebase-tests/rules.test.js`; `test/admin/admin_hostels_approve_test.dart` (new).

**Rules change (decided by the user: the owner must see the rejection reason):** `firestore.rules:180-183` lets an admin change only `status`. Widen it to `hasOnly(['status', 'rejectionReason'])`, and add `rejectionReason` (optional string, at most 500 characters) to `isValidHostelData()`. Owners cannot set it: the owner update rule must keep `rejectionReason` equal to its current value (same pattern as `rating`/`viewCount`). Deploy with `firebase deploy --only firestore:rules`.

**Interfaces:**
- Produces: `HostelModel.rejectionReason` (`String?`, in `copyWith`/`==`/`hashCode`/`fromFirestore`; `toFirestore` omits it when null); `Future<void> HostelRepository.setStatus(String hostelId, ListingStatus status, {String? rejectionReason})` (updates only `status` and, for rejection, `rejectionReason`; approving clears it); `AdminHostelsController.approve(HostelModel)` and `reject(HostelModel, String reason)` (reject opens a dialog with a required reason field, max 500 characters; snackbar on success/failure).

- [ ] **Step 1: Failing tests:** `setStatus writes only status (and rejectionReason)` (fake Firestore, other fields unchanged); `approve moves pending → published and clears a previous reason`; `reject moves pending → rejected and stores the reason`; `reject with an empty reason is refused`; the Hostels table shows Approve/Reject only on `pending` rows. Rules tests (`rules.test.js`, cannot run here, no Java): admin may set `rejectionReason`; owner may not.
- [ ] **Step 2: Run:** FAIL. **Step 3: Implement** (reuse the table's action-column pattern next to the delete icon and the existing reject-reason dialog pattern from the Verifications review). **Step 4: Run:** PASS.
- [ ] **Step 5: Commit** `feat(admin): approve or reject pending hostels with a reason`.

### Task 5b: Owner sees the rejection reason on the Home (Dashboard)

**Files:** `dashboard_view.dart`, `dashboard_controller.dart`, `app_strings.dart`; `test/owner/dashboard_rejection_test.dart` (new).

**Interfaces:**
- Consumes: `HostelModel.rejectionReason`, `ListingStatus.rejected`.
- Produces: `List<HostelModel> DashboardController.rejectedListings` (status `rejected`, newest first); `AppStrings.rejectedHostelTitle(String hostelName)` and `AppStrings.rejectedHostelFallbackReason` (shown when the reason is empty, for example an older rejection).

- [ ] **Step 1: Failing tests:** a rejected hostel with reason `Photos are blurry` shows an alert on the Dashboard containing the hostel name and exactly that reason; a rejected hostel without a reason shows the fallback text; two rejected hostels show two alerts; no alert when nothing is rejected; an approved or pending hostel never shows one.
- [ ] **Step 2: Run:** FAIL. **Step 3: Implement** with the existing `AlertCard`, placed under the verification alert, each with a button that opens that hostel in Edit mode so the owner can fix it and publish again (resubmitted rejected hostels count toward the 3-in-review cap like any pending one). **Step 4: Run:** PASS.
- [ ] **Step 5: Commit** `feat(owner): show hostel rejection reason on the Dashboard`.

### Task 6: Verify end to end

- [ ] **Step 1:** `flutter analyze` (0 issues) and `flutter test` (0 failures). Goldens may need `--update-goldens` only if a shared widget changed (none planned).
- [ ] **Step 2: Manual pass** with an owner account and the admin panel: submit verification with hostel 1; press Done and switch every tab; add hostels 2 and 3 from the Add tab; confirm the 4th is blocked with the limit message; in the admin panel approve the identity, then approve hostels 2 and 3 on the Hostels tab; confirm the owner can add more and the Dashboard says `Welcome, {name}`.
- [ ] **Step 3: Commit** any fixes.

## Decisions confirmed by the user (2026-11-14)

1. Max 3 hostels in review at the same time while the owner is unverified: confirmed.
2. Verified owners: no cap on the number of hostels (confirmed by answer "what cap?").
3. Rejecting a hostel requires a reason, and the owner sees it on the Home (Dashboard): confirmed. This adds Task 5b and a rules change (deploy needed).
