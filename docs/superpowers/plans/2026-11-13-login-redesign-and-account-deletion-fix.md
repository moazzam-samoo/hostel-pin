# Login Redesign, Account-Type Switch and Account-Deletion Fix: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (or subagent-driven-development) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make the Login screen fit without scrolling (small logo beside the welcome text), restyle the Google button, add Terms/Privacy consent text, add a Student/Owner switch on Login, and find and fix why account deletion fails.

**Architecture:** Flutter + GetX MVVM. UI changes stay in `features/auth/` and the shared `GoogleAuthButton`; all colors, sizes and copy go through `AppColors`/`AppSizes`/`AppTextStyles`/`AppStrings`. Account-type state already lives in `AuthController.selectedRole` and is reused. Deletion work stays in `features/account/` and `data/repositories/account_repository.dart`.

**Tech Stack:** Flutter 3.44, GetX, flutter_screenutil (375x812 baseline), flutter_test.

**Spec:** the user's request of 2026-11-13 (no separate design doc). Open questions are in the section "Decisions needed from you" and block the tasks that name them.

## Global Constraints

- No hardcoded `Color`, `TextStyle`, radius, spacing or user-facing string in `features/` or `shared/widgets/`; add tokens/strings instead.
- Reuse existing widgets before creating new ones: `PrimaryButton` (height `AppSizes.buttonHeight` = 48.h), `TextLinkButton`, `AuthDivider`, `AuthFooterPrompt`, `TermsCheckbox` link style.
- Views are `GetView<T>`; state lives in controllers; every screen keeps its View + Controller + Binding triplet.
- Support layouts from 320x568 up; text scale clamped 1.0 to 1.3 (already in `app.dart`).

## Review Focus

- Small phone (320x568) and 1.3x text: Login must not overflow; scrolling is allowed as a safety net there but must not be needed at 375x812.
- A user who picks "Owner" on Login but whose existing account is a Student: stored role wins today. The screen must say so instead of silently showing the wrong app.
- Google sign-in with the switch set to Owner for a brand-new Google identity: the account is created as Owner.
- Deletion when rules are not deployed, offline, or the Google picker is cancelled: the user must see a specific, truthful message, never a stuck spinner.
- Logo image missing/placeholder size: layout must not shift the title off-screen at 1.3x text.

---

## Findings that drive the plan

**Account deletion.** Reading `AccountController` -> `AccountRepository.deleteUserData` -> `AuthService.deleteAccount`, the code path is complete. The most likely reason it "does not delete" is that the new Firestore rule `allow delete: if request.auth.uid == userId || isAdmin()` on `users/{uid}` **has not been deployed**: the deployed rules still say `allow delete: if isAdmin()`, so the final profile delete returns `permission-denied`. Today that error is swallowed into the generic "Could not delete your account", which hides the real cause. Task 1 proves or disproves this with evidence before changing anything. (Secondary candidates: owner-only collections denied for a student, a stale `google-services.json`/offline state, Google users cancelling re-auth.)

**Login layout.** `login_view.dart` stacks title, subtitle, a 145r logo (`AppSizes.authLogo`), two fields, forgot link, button, divider, Google button, footer: it cannot fit 812 px, so it scrolls.

**Google button.** `GoogleAuthButton` is content-width (padding 24x12), icon 24, label "Google" in `AppTextStyles.button`. It is shared with Signup.

**Account type.** `AuthController.selectedRole` is set only on `RoleSelectionView`; Login has no control. An existing account's stored `users/{uid}.role` always wins at login (by design, Block F), so the switch only changes behavior for **new** accounts (Signup, first-time Google).

## File Structure

| File | Change |
|---|---|
| `lib/features/account/account_controller.dart` | Task 1: log real error, map `permission-denied` to a specific message |
| `lib/core/constants/app_strings.dart` | Tasks 1 to 5: new strings only |
| `lib/core/constants/app_sizes.dart` | Task 2: `authLogoSmall` |
| `lib/features/auth/view/login_view.dart` | Tasks 2 to 5: new layout |
| `lib/shared/widgets/buttons/google_auth_button.dart` | Task 3: full-width, label, sizes |
| `lib/features/auth/widgets/terms_notice.dart` (new) | Task 4: "By continuing you agree..." with two links |
| `lib/features/auth/widgets/account_type_switch.dart` (new) | Task 5: Student/Owner segmented control |
| `lib/features/auth/controller/login_controller.dart` | Task 5: role-mismatch message |
| `test/auth/login_view_test.dart` (new) | Tasks 2 to 5 tests |

---

### Task 1: Find and fix the account-deletion failure

**Files:**
- Modify: `lib/features/account/account_controller.dart`, `lib/core/constants/app_strings.dart`
- Test: `test/data/release_repositories_test.dart` (extend), `firebase-tests/rules.test.js` (already covers self-delete)

**Interfaces:**
- Produces: `AppStrings.deleteAccountPermissionDenied`; `Logger.e` line `Account deletion failed: <exception>` carrying the real exception.

- [ ] **Step 1: Prove the cause.** Ask the user to run `firebase deploy --only firestore:rules,firestore:indexes` (CLI 15.10.1 is installed) and retry Delete Account. Separately run the app with `flutter run` and capture the console line `Account data deletion failed:`; a `permission-denied` there confirms the hypothesis. Expected: after deploying, deletion succeeds.
- [ ] **Step 2: Failing test.** In `release_repositories_test.dart` add `AccountRepository surfaces a typed Failure when Firestore rejects a delete` using a `FakeFirebaseFirestore` subclass/wrapper that throws `FirebaseException(code: 'permission-denied')` on `users/{uid}` delete; assert `deleteUserData` throws `Failure`. Run: `flutter test test/data/release_repositories_test.dart`. Expected: FAIL until Step 3 if the exception type is lost.
- [ ] **Step 3: Implement** in `AccountController._deleteEverything`: log the raw exception with `Logger.e`, and choose the message by cause: `permission-denied` -> `AppStrings.deleteAccountPermissionDenied` ("Could not delete. Please update the app or contact support."), `requires-recent-login` -> existing message, anything else -> existing generic. Also catch non-`Failure` exceptions so the spinner can never hang.
- [ ] **Step 4: Verify.** `flutter test`, then manual: delete a throwaway student account and a throwaway owner account against the deployed rules; confirm `users/{uid}`, `users/{uid}/saved/*`, owner `hostels`, `activities`, `verifications/{uid}` are gone in the console and the Auth user is gone (logging in again fails). Expected: all gone.
- [ ] **Step 5: Commit** `fix(account): surface real deletion errors and map permission-denied`.

### Task 2: Login layout with small logo beside the welcome text

**Files:**
- Modify: `lib/features/auth/view/login_view.dart`, `lib/core/constants/app_sizes.dart`
- Test: `test/auth/login_view_test.dart`

**Interfaces:**
- Produces: `AppSizes.authLogoSmall` (`double get`, `56.r`).

- [ ] **Step 1: Failing test** `Login needs no scrolling at 375x812`: pump `LoginView` with `LoginController` + `AuthController` registered (same fake-session pattern as `test/responsive/screen_size_test.dart`), read the `Scrollable` state, assert `position.maxScrollExtent == 0`. Add `no overflow at 320x568 and 1.3x text` using `tester.takeException()` is null. Run `flutter test test/auth/login_view_test.dart`. Expected: first test FAILS today.
- [ ] **Step 2: Implement.** Replace the title block with a `Row`: `Expanded(Column(title, subtitle))` on the left, `Image.asset(AppAssets.appLogo, width/height: AppSizes.authLogoSmall)` on the right (drop `ConfettiDots` here and the 145r centered logo and its two `SizedBox`es). Tighten spacing (`AppSpacing.md` between groups). Keep `SingleChildScrollView` as a safety net.
- [ ] **Step 3: Run tests**; both pass. Manual check on a 320x568 emulator.
- [ ] **Step 4: Commit** `feat(auth): compact login header with small logo`.

### Task 3: Google button restyle (shared widget)

**Files:**
- Modify: `lib/shared/widgets/buttons/google_auth_button.dart`, `lib/core/constants/app_strings.dart` (`continueWithGoogle`), `lib/features/auth/view/login_view.dart`, `lib/features/auth/view/signup_view.dart`
- Test: `test/widgets/shared_widgets_test.dart` (extend)

**Interfaces:**
- Produces: `GoogleAuthButton({required VoidCallback onPressed, bool isLoading = false})` unchanged signature; now full width, `height: AppSizes.buttonHeight`, 20r icon, label `AppStrings.continueWithGoogle` at `AppTextStyles.button` reduced to about 14.sp via `copyWith`.

- [ ] **Step 1: Failing test** `GoogleAuthButton matches PrimaryButton height and shows the new label`: pump both, compare `tester.getSize(find.byType(GoogleAuthButton)).height` to `AppSizes.buttonHeight`, and `find.text('Continue with Google')`. Expected FAIL now (content-sized, label "Google").
- [ ] **Step 2: Implement.** Wrap in `SizedBox(width: double.infinity, height: AppSizes.buttonHeight)`, center the `Row`, keep the loading spinner at the same 20r box. Remove the `Center(...)` wrappers in Login/Signup so the button spans the width.
- [ ] **Step 3: Run** `flutter test test/widgets/shared_widgets_test.dart`. Expected PASS. Regenerate nothing: `GoogleAuthButton` has no golden.
- [ ] **Step 4: Commit** `feat(auth): full-width Google button with smaller label`.

### Task 4: Terms and Privacy consent text on Login

**Files:**
- Create: `lib/features/auth/widgets/terms_notice.dart`
- Modify: `lib/features/auth/view/login_view.dart`, `lib/core/constants/app_strings.dart` (`loginAgreePrefix` = "By logging in, you agree to our ")
- Test: `test/auth/login_view_test.dart`

**Interfaces:**
- Produces: `TermsNotice({super.key, required String prefix})` (stateless; taps call `Get.toNamed(Routes.termsOfService)` / `Routes.privacyPolicy`).
- Consumes: `AppStrings.termsTitle`, `AppStrings.privacyPolicyTitle`, `AppStrings.termsAgreeAnd`, the link style from `terms_checkbox.dart`.

- [ ] **Step 1: Failing test** `tapping the Privacy Policy link on Login opens the privacy route`: pump `LoginView` in a `GetMaterialApp` with a stub page for `Routes.privacyPolicy`, tap `find.text('Privacy Policy')`, expect the stub page. Expected FAIL (no link).
- [ ] **Step 2: Implement** `TermsNotice` as a centered `Wrap` of text + two underlined `InkWell` links, in `AppTextStyles.caption`; place it under the Google button, above the footer prompt. Optionally reuse it from `TermsCheckbox` later (not in this plan).
- [ ] **Step 3: Run tests**, expect PASS; re-run the Task 2 no-scroll test (this adds about 40 px, so spacing may need another pass).
- [ ] **Step 4: Commit** `feat(auth): terms and privacy consent notice on login`.

### Task 5: Student/Owner switch on the Login screen

**Files:**
- Create: `lib/features/auth/widgets/account_type_switch.dart`
- Modify: `lib/features/auth/view/login_view.dart`, `lib/features/auth/controller/login_controller.dart`, `lib/core/constants/app_strings.dart`
- Test: `test/auth/login_view_test.dart`

**Interfaces:**
- Produces: `AccountTypeSwitch({super.key, required UserRole? selected, required ValueChanged<UserRole> onChanged})` (two segments labelled `AppStrings.studentSectionTitle` / `ownerSectionTitle`); `LoginController.setRole(UserRole role)` writes `authController.selectedRole.value`.
- Consumes: `AuthController.selectedRole` (`Rx<UserRole?>`), `AuthRepository.signInWithGoogleAndResolveRole(fallbackRole)` (already uses `selectedRole`).

- [ ] **Step 1: Failing tests.** (a) `switch shows the role picked at Role Selection and changes it`: set `selectedRole = student`, tap "Owner", expect `selectedRole.value == UserRole.owner`. (b) `role mismatch is explained`: stub `AuthRepository`/`UserRepository` so the signed-in doc is a Student while `selectedRole` is Owner; after `submit()` expect a snackbar message `AppStrings.loginRoleMismatch('Student')`.
- [ ] **Step 2: Implement** the segmented control above the email field, compact (height about 40.h), wrapped in `Obx`. In `LoginController.submit` and `signInWithGoogle`, after resolving the stored role, if it differs from `selectedRole`, show `AppStrings.loginRoleMismatch(storedRole)` ("This is a Student account, so we opened it as Student.") before navigating.
- [ ] **Step 3: Run tests**, expect PASS; re-run the no-scroll test and, if it fails, drop the subtitle line (decision below).
- [ ] **Step 4: Commit** `feat(auth): student/owner switch on login with role-mismatch message`.

### Task 6: Whole-suite verification

- [ ] **Step 1:** `flutter analyze` (expect 0 issues) and `flutter test` (expect 0 failures). 
- [ ] **Step 2:** Manual pass on a real phone or emulator: Login at 375x812 shows no scroll; Google button height equals Login button; both legal links open; switching to Owner then Google sign-in with a new account creates an Owner; Delete Account works for student and owner.
- [ ] **Step 3: Commit** any test-only fixes.

---

## Decisions needed from you (please answer before I implement)

1. **"Google icon same size as the Login button."** I read this as: the Google button becomes **full width and the same height (48) as the Login button**, with a 20px icon inside. If you meant the icon itself should be as large as the button, tell me.
2. **Label.** Use "Continue with Google" at a smaller font (about 14 sp vs 16 now). The divider above it currently says "or Continue with", which would repeat; I propose changing it to just **"or"**. OK?
3. **Signup.** `GoogleAuthButton` is shared, so Signup gets the same new button automatically. Fine, or Login only?
4. **Account type behavior.** One email = one role, and the stored role wins on login. The switch therefore only affects **new** accounts, and I show a message when it disagrees with an existing account. Is that what you want, or do you need the same person to hold both a student and an owner account (a much bigger change to the data model and rules)?
5. **No-scroll goal.** Adding the switch and consent text may not fit 568 px tall phones. Allow scrolling only on small phones, or drop the subtitle ("Hello there, sign in to continue") to save space?
6. **Logo size.** About 56 px beside the title. Larger or smaller?
7. **Account deletion.** Did you deploy the Firestore rules (`firebase deploy --only firestore:rules,firestore:indexes`) before testing deletion? If it still fails after deploying, paste the console line starting with `Account data deletion failed:` so I can see the real error.
