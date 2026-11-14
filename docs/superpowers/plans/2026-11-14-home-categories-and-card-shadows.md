# Home Page: Boys/Girls Categories and Soft Card Shadows: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (or subagent-driven-development) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make the Home page match the supplied screenshot: working All / Boys / Girls category chips that filter the hostels, and softer, borderless card shadows.

**Architecture:** Hostels gain a `gender` field (`boys` | `girls`) that owners set when listing. Home filters server-side by that field (so pagination stays correct), with the selected chip held in `HomeController`. Card look is controlled by one new shadow token plus a new `HostelCardSurface`.

**Tech Stack:** Flutter 3.44, GetX, Cloud Firestore (composite index), flutter_screenutil, fake_cloud_firestore for tests.

**Spec:** the user's screenshot (`images/4.png`, Home screen) and message of 2026-11-14; open questions below.

## What the screenshot shows (compared with the current code)

| # | Screenshot | Current code |
|---|---|---|
| 1 | Chip row **All (selected, purple) / Boys / Girls** under "Featured Hostels" | No chip row exists; no gender data exists anywhere (`HostelModel` has no such field) |
| 2 | Cards are white with **no visible border** and a **soft, wide shadow** | List cards use `tonal`: white + 1px border, **no shadow**; featured uses `elevated`: border + a weak shadow (alpha 0.05, blur 10) |
| 3 | Featured card: image **inset inside the card** with padding, near square, name + arrow, heart on the right, "Owner : …" | Image is full-bleed at the top (16:10), clipped to the card |
| 4 | Featured cards are about 70% of the screen width, the next one peeks | `viewportFraction: 0.76`, fixed `height: 290` |
| 5 | **No "All Hostels" heading** between the carousel and the list | `SectionHeader(allHostelsSection)` is shown |
| 6 | Search bar is white with a thin grey border | `AppSearchBar` is a filled `primaryContainer` bar without border (to confirm on device) |
| 7 | Price reads `Rs:12000/mnth` | Code renders `Rs 12,000/mnth` (comma, no colon) |

Items 6 and 7 may just be mockup differences; I will only change them if you confirm.

## Global Constraints

- No hardcoded colors, text styles, radii, spacing or strings in `features/` or `shared/widgets/`; add tokens and `AppStrings` entries.
- Reuse before creating: `AccountTypeSwitch` (the Student/Owner toggle I just built) becomes a generic shared segmented control; `HostelCard`, `EmptyState`, `StateView` stay.
- Existing hostels have **no** `gender`: they must still appear under **All**, and nothing may crash on a missing field.
- Firestore rules and indexes must be deployed together with the app build (a missing index makes Home show an error).

## Review Focus

- Existing hostels without `gender`: visible under All, hidden under Boys/Girls, no crash.
- Switching chips while more pages are loading: no stale results from the previous chip, no duplicate subscriptions.
- A category with zero hostels: a clear empty message for that category, not the global "no hostels yet" screen.
- Owner edits an old hostel: the form requires choosing a gender before saving.
- Very small phone and 1.3x text: chip row must not overflow (it scrolls horizontally).

## File Structure

| File | Change |
|---|---|
| `lib/core/enums/hostel_gender.dart` (new) | `enum HostelGender { boys, girls }` with `label` |
| `lib/data/models/hostel_model.dart` | `final HostelGender? gender`; `copyWith`, `==`, `hashCode`, `fromFirestore`, `toFirestore` |
| `lib/data/repositories/hostel_repository.dart` | `streamAllPublished({int limit, HostelGender? gender})` |
| `firestore.indexes.json`, `firestore.rules` | index `status, gender, __name__ DESC`; rule: `gender` (when present) in `['boys','girls']` |
| `lib/shared/widgets/inputs/segmented_toggle.dart` (new) | generic `SegmentedToggle<T>`; `AccountTypeSwitch` delegates to it |
| `lib/shared/widgets/inputs/category_chip_row.dart` (new) | All/Boys/Girls chips (selected purple pill, others white) |
| `lib/features/student/home/home_controller.dart`, `home_view.dart` | `selectedGender`, chip row, re-subscribe, per-category empty state, remove "All Hostels" heading |
| `lib/features/student/home/widgets/featured_carousel.dart` | viewport/height tuning |
| `lib/shared/widgets/cards/hostel_card.dart`, `lib/core/theme/app_shadows.dart` | `HostelCardSurface.soft`, `AppShadows.softCard`, inset-image featured layout |
| `lib/features/owner/add_listing/add_listing_{view,controller}.dart`, `owner/verification/steps/step3_hostel_info.dart`, `verification_controller.dart` | "Hostel type" selector (required) |
| `lib/core/constants/app_strings.dart` | labels and empty-state copy |

---

### Task 1: Gender in the data layer

**Files:** `hostel_gender.dart` (new), `hostel_model.dart`, `hostel_repository.dart`, `firestore.indexes.json`, `firestore.rules`; tests in `test/data/release_repositories_test.dart` and `firebase-tests/rules.test.js`.

**Interfaces:**
- Produces: `enum HostelGender { boys, girls }` (`String get label`); `HostelModel.gender` (`HostelGender?`, null for legacy docs); `HostelRepository.streamAllPublished({int limit = kHostelPageSize, HostelGender? gender}) -> Stream<List<HostelModel>>`.

- [ ] **Step 1: Failing tests.** `streamAllPublished(gender: boys) returns only boys hostels, newest first` (seed 3 boys, 2 girls, 1 legacy without field); `streamAllPublished() still returns all 6`; `HostelModel round-trips gender and tolerates a missing field`. Run `flutter test test/data/release_repositories_test.dart`; expected FAIL (field missing).
- [ ] **Step 2: Implement** the enum, model field (serialized as `gender: 'boys'|'girls'`, omitted when null), and the repository filter `.where('gender', isEqualTo: gender.name)` before `orderBy(documentId, desc)`.
- [ ] **Step 3: Index and rule.** Add composite index `status ASC, gender ASC, __name__ DESC`. Extend `isValidHostelData()` with `(!('gender' in d) || d.gender in ['boys','girls'])`; add rules tests: invalid value rejected, absent field allowed.
- [ ] **Step 4: Verify** `flutter test` passes; rules tests need Java (cannot run here).
- [ ] **Step 5: Commit** `feat(data): hostel gender field, filtered stream, index and rule`.

### Task 2: Owners choose the hostel type

**Files:** `segmented_toggle.dart` (new), `account_type_switch.dart` (refactor), the four owner files listed above, `app_strings.dart`; test `test/owner/hostel_type_selector_test.dart`.

**Interfaces:**
- Produces: `SegmentedToggle<T>({required List<SegmentOption<T>> options, required T? selected, required ValueChanged<T> onChanged})` with `SegmentOption<T>({required T value, required String label})`.
- Consumes: `HostelGender`; `AddListingController.gender` (`Rxn<HostelGender>`), `VerificationController.hostelGender` (same type).

- [ ] **Step 1: Failing tests.** `SegmentedToggle renders options and reports taps`; `Add Listing cannot publish until a hostel type is chosen` (controller `isValid` false until set); existing `login_view_test.dart` must still pass after the refactor.
- [ ] **Step 2: Implement** the generic toggle (moving the current segment styling), make `AccountTypeSwitch` a thin wrapper, add the "Hostel type" field (Boys | Girls) to Add Listing and wizard step 3, prefill in edit mode, include `gender` in the saved `HostelModel`, and add it to `isValid` and validation.
- [ ] **Step 3: Run** `flutter test`; expected PASS.
- [ ] **Step 4: Commit** `feat(owner): required hostel type (boys/girls) on listings`.

### Task 3: Home category chips and filtering

**Files:** `category_chip_row.dart` (new), `home_controller.dart`, `home_view.dart`, `app_strings.dart`; test `test/student/home_categories_test.dart`.

**Interfaces:**
- Produces: `CategoryChipRow({required HostelGender? selected, required ValueChanged<HostelGender?> onChanged})` (null = All); `HomeController.selectedGender` (`Rxn<HostelGender>`), `HomeController.selectGender(HostelGender? g)`.

- [ ] **Step 1: Failing tests** (fake Firestore + faked session, same pattern as `login_view_test.dart`): `tapping Boys shows only boys hostels`; `tapping Girls then All restores the full list`; `a category with no hostels shows its own empty message`; `legacy hostel without gender appears under All only`. Expected FAIL.
- [ ] **Step 2: Implement.** `selectGender` resets `pageLimit` to `kHostelPageSize`, cancels `_publishedSub`, and re-runs `_loadData()` with the gender; the chip row sits under the "Featured Hostels" heading; `HomeView` removes the "All Hostels" heading (screenshot) and shows a per-category empty state (`AppStrings.noHostelsInCategory(label)`) instead of the global one.
- [ ] **Step 3: Run tests**; expected PASS. Check at 320x568 and 1.3x text that the chip row has no overflow.
- [ ] **Step 4: Commit** `feat(home): boys/girls/all category chips with server-side filtering`.

### Task 4: Soft card shadows and screenshot-style featured card

**Files:** `app_shadows.dart`, `hostel_card.dart`, `featured_carousel.dart`, `home_view.dart`; goldens `test/golden/goldens/hostel_card_*.png`.

**Interfaces:**
- Produces: `AppShadows.softCard` (`List<BoxShadow>`: black at about 0.08 alpha, blur about 24, offset `(0, 8)`); `HostelCardSurface.soft` (white, **no border**, `softCard` shadow).

- [ ] **Step 1: Failing test** `soft surface has no border and a shadow`: pump `HostelCard(surface: soft)`, find its `DecoratedBox`/`Container`, assert `border == null` and `boxShadow == AppShadows.softCard`. Expected FAIL.
- [ ] **Step 2: Implement** the token and surface; Home list cards and the carousel use `soft`. Featured layout: image inset with `AppSpacing.md` padding on all sides and a rounded corner, near-square (aspect about 1:1), viewport about 0.70, carousel height tuned to fit (about 300 at 375 wide). Keep other screens as they are unless you choose the app-wide option below.
- [ ] **Step 3: Regenerate goldens** (`flutter test --update-goldens test/golden/shared_widgets_golden_test.dart`), then `flutter test` full run; expected PASS.
- [ ] **Step 4: Commit** `feat(ui): soft borderless card shadows and inset featured image`.

### Task 5: Deploy and verify

- [ ] **Step 1:** `flutter analyze` (0 issues) and `flutter test` (0 failures).
- [ ] **Step 2:** `firebase deploy --only firestore:rules,firestore:indexes`; wait until the new index shows Enabled.
- [ ] **Step 3:** Manual pass: create one Boys and one Girls hostel as an owner (admin approves), check Home chips; confirm legacy hostels appear under All; compare the screen to the screenshot.
- [ ] **Step 4: Commit** any fixes.

---

## Decisions needed from you

1. **Existing hostels have no boys/girls value.** Show them only under **All** until the owner edits them (my recommendation), or should I give them a default such as Boys?
2. **Co-ed hostels.** Offer only Boys and Girls (matches the chips), or also a third "Both" option that appears under Boys and Girls?
3. **Shadow scope.** Change the soft shadow only on Home (list and featured cards), or on **every** hostel card (Search, Saved, Map)? App-wide is more consistent, but it changes those screens too.
4. **"All Hostels" heading.** The screenshot has none, so I would remove it. OK?
5. **Featured section and categories.** Should the Boys and Girls chips also filter the **Featured** carousel (my recommendation), or only the list below?
6. **Search bar and price text.** Your screenshot shows a white bordered search bar and prices like `Rs:12000/mnth`. Should I change these too, or keep the current ones?
7. **Owners.** Selecting Boys or Girls becomes **required** when an owner adds or edits a hostel (it also appears in the verification wizard). OK?
