# Developer Guidance — Hostel Finder

**Developed by Moazam Samoo**

This file is the human-readable onboarding guide for this codebase: how it's organized, how state management works, what's actually been built, and the conventions to follow if you're continuing the work. If you want the exhaustive, continuously-re-verified reference (every widget, every parameter, every navigation edge traced from real code).

---

## 1. Folder structure

```
hostel_finder_app/
├── lib/
│   ├── app.dart                    # GetMaterialApp: theme, routes, initial binding, text-scale clamp
│   ├── main.dart                   # App entry point — ScreenUtilInit wraps everything for responsive scaling
│   │
│   ├── core/                       # Nothing feature-specific lives here — pure shared foundation
│   │   ├── bindings/
│   │   │   └── initial_binding.dart    # Registers app-wide singletons (currently: MockDataService)
│   │   ├── constants/
│   │   │   ├── app_assets.dart         # Every image/icon path, as a named constant
│   │   │   ├── app_durations.dart      # Animation/timing constants
│   │   │   ├── app_sizes.dart          # Component dimensions (button height, icon sizes, ...)
│   │   │   └── app_strings.dart        # Every piece of user-facing copy in the app
│   │   ├── enums/                      # Amenity, UserRole, ListingStatus, AvailabilityStatus, ViewState
│   │   ├── errors/                     # Failure type + error mapper (stub — real mapping lands with Firebase)
│   │   ├── middleware/                 # Auth/role route guards (stubs — activated once Firebase auth exists)
│   │   ├── routes/
│   │   │   ├── app_routes.dart         # Every route name, as a string constant
│   │   │   └── app_pages.dart          # Maps each route to its View + Binding
│   │   ├── theme/                      # AppColors, AppTextStyles, AppRadius, AppSpacing, AppShadows, AppTheme
│   │   └── utils/                      # Formatters, Validators, Logger, Responsive helpers
│   │
│   ├── data/                       # The "Model" side of MVVM
│   │   ├── models/                     # HostelModel, UserModel — plain Dart classes, no Firebase imports
│   │   ├── mock/                       # Mock hostel list + mock user, used until a real backend exists
│   │   ├── repositories/               # Empty today — this is where Firestore-backed repositories will live
│   │   └── services/
│   │       └── mock_data_service.dart  # Today's stand-in "backend" — see §2
│   │
│   ├── features/                   # One folder per screen or flow — this is where you'll spend most of your time
│   │   ├── splash/, welcome/, role_selection/, auth/    # Onboarding + authentication (done)
│   │   ├── student/                                     # Every student-facing screen (done)
│   │   │   ├── shell/          # The bottom-nav container (Home/Map/Saved/Profile tabs)
│   │   │   ├── home/, map/, saved/, search/, profile/, hostel_detail/
│   │   └── owner/                                       # Empty — not started yet
│   │
│   └── shared/                     # Reusable UI building blocks — the "don't repeat yourself" layer
│       ├── widgets/                    # 54 shared widgets: buttons/, cards/, inputs/, layout/, feedback/, media/, navigation/
│       ├── widget_gallery/             # A debug screen (/widget-gallery) that renders every shared widget — useful for visual QA
│       └── extensions/                 # Small Dart extension methods (on BuildContext, num, String)
│
├── assets/                         # Fonts, icons, illustrations, images
└── test/                           # Widget tests
```

**The rule that keeps this organized:** every screen composes widgets from `shared/widgets/` rather than building its own version of a button, card, or input field. Before adding a new UI element, check `shared/widgets/` first — there's a good chance something close already exists and just needs a new parameter.

---

## 2. State management — GetX

This project uses **[GetX](https://pub.dev/packages/get)** for three things at once: reactive state, navigation, and dependency injection. If you've used `Provider` or `Riverpod` before, the mental model is similar but GetX bundles all three concerns into one package.

### The three building blocks

**Controllers** (`GetxController`) hold all state and business logic for a screen. A controller never touches `BuildContext` or widgets directly — it exposes state as observable fields and exposes methods the View calls in response to user actions.

```dart
class HomeController extends GetxController {
  final status = StateViewStatus.loading.obs;   // .obs makes a field "observable"
  final featuredHostels = <HostelModel>[].obs;

  void toggleSaved(String hostelId) { ... }
}
```

**Views** are `StatelessWidget`s that extend `GetView<T>` (where `T` is the controller type). `GetView` gives you a `controller` getter for free — no manual lookup needed. Views wrap any part of the UI that needs to react to state changes in `Obx(() => ...)`, which rebuilds automatically whenever an observable it reads changes.

```dart
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => StateView(
      state: controller.status.value,
      contentBuilder: ...,
    ));
  }
}
```

**Bindings** (`Bindings`) are where a controller gets created and registered, tied to a specific route. This keeps controller *construction* out of the View entirely.

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

Every route in `core/routes/app_pages.dart` pairs a `View` with a `Binding`:

```dart
GetPage(
  name: Routes.studentHome,
  page: () => const HomeView(),
  binding: HomeBinding(),
),
```

### Dependency injection patterns actually used in this codebase

- `Get.lazyPut<T>(() => T())` — the default. Creates the controller the first time it's needed, disposes it when nothing references it anymore.
- `Get.put(T(), permanent: true)` — used for things that must survive across the whole app (e.g. `AuthController`'s shared `selectedRole` state).
- `Get.putAsync(() => T().init(), permanent: true)` — used once, in `InitialBinding`, to register `MockDataService` and let it load its mock data asynchronously before anything else runs.
- **One binding can register several controllers.** `AuthBinding` registers six controllers (shared `AuthController` + five screen controllers) because all five auth screens are reachable from routes that share that one binding. `StudentShellBinding` does the same for the four bottom-nav tabs, since they're all children of one shell screen rather than separately-routed pages.

### Navigation

All navigation goes through `Get.toNamed(...)`, `Get.offNamed(...)`, `Get.offAllNamed(...)`, or `Get.back()` — never Flutter's raw `Navigator`. The difference matters:
- `Get.toNamed` — push a new screen, keep the back stack.
- `Get.offNamed` — replace the current screen (no way back to it).
- `Get.offAllNamed` — clear the entire stack and start fresh (used after login/logout, so the back button can't return to a screen that's no longer valid).

**One structural exception worth knowing:** the student bottom-navigation tabs (Home / Map / Saved / Profile) are **not** separate routes. `StudentShellView` holds all four as children of a single `IndexedStack` and switches between them by changing an index (`StudentShellController.currentIndex`), not by navigating. This means switching tabs doesn't rebuild them or lose their scroll position. Only screens *pushed above* the shell — Hostel Detail, Search, Edit Profile, etc. — are real named routes.

---

## 3. Architecture — MVVM, strictly separated

| Layer | Lives in | Responsible for |
|---|---|---|
| **Model** | `data/models/` | Plain data classes. No widgets, no GetX, no business rules. |
| **Service** | `data/services/` | Talks to a data source (today: the in-memory `MockDataService`; eventually: Firebase/Firestore wrappers). |
| **Repository** *(not built yet)* | `data/repositories/` | Will be the only layer allowed to call a service directly, once a real backend exists. |
| **Controller (ViewModel)** | `features/*/...controller.dart` | All state, all logic, all navigation decisions. |
| **View** | `features/*/...view.dart` | Layout only. Reads controller state, calls controller methods. Never contains business logic. |
| **Shared widget** | `shared/widgets/` | Pure, reusable, parameterized — inputs in, callbacks out. Never reaches into a controller or a data service. |

The rule that's checked repeatedly throughout this project's build history: **a View file should never construct a `TextEditingController`, branch on business logic, or call a data service directly.** If you're writing an `if` statement that decides *what happens*, it belongs in the controller, not the view.

---

## 4. What has been built — Auth + Student role, UI only

### ✅ Done

**Foundation** — the full design-token system (`AppColors`, `AppTextStyles`, `AppRadius`, `AppSpacing`, `AppShadows`) and a library of 54 reusable widgets covering every button, card, input, and layout pattern the app needs.

**Authentication flow** (`features/splash/`, `welcome/`, `auth/`, `role_selection/`) — Splash → Welcome → Login/Signup → Role Selection → student or owner shell. Forgot Password, a "check your email" confirmation, and an in-app Change Password + success screen are all built. Every "network call" here is simulated with a short delay (`Future.delayed`) — there is no real authentication happening yet, no passwords are actually verified against anything.

**Student role — every screen** (`features/student/`):
- **Home** — featured hostel carousel + full listing, search bar entry point
- **Map** — Google Map with hostel markers, tap-to-preview, current-location button
- **Hostel Detail** — photo gallery, facilities, description, location preview, Call/WhatsApp actions
- **Saved** — saved hostels list with an empty state and "you might also like" suggestions
- **Search & Filter** — live search, price range, amenity filters, sort options
- **Profile** — account settings, preferences, saved-hostel count, change password, logout

All of it runs against **mock data** (`data/mock/mock_hostels.dart`, `data/mock/mock_user.dart`) served through `MockDataService`, an in-memory `GetxService` that acts as a temporary stand-in for a real backend. Saved/heart state is reactive and stays in sync across every screen that shows it (Home, Map, Saved, Search, Profile all read/write the same shared state).

### 🔲 Not done

- **Owner role** — no screens exist yet (dashboard, listing management, add-listing form). `features/owner/` is empty.
- **Real backend** — NO Backend is conneced yet(Auth), `pubspec.yaml` has none of these dependencies yet. Nothing persists between app restarts except what's already baked into the mock data.
- Anything that depends on the above: real login, real image uploads, real saved-state persistence, push notifications, payments.

If a screen exists in the app today, its **UI is finished** — what's missing everywhere is the backend underneath it.

---

## 5. Conventions to follow

1. **Reuse before you build.** Check `shared/widgets/` (or `AGENTS.md`'s widget index) before creating anything new. Extend an existing widget with a parameter rather than duplicating it with small differences.
2. **No hardcoded values.** Colors, text styles, spacing, radii, and every piece of user-facing text go through the token classes (`AppColors`, `AppTextStyles`, etc.) and `AppStrings` — never a raw `Color(0x...)`, inline `TextStyle(...)`, or a string literal typed directly into a `Text(...)` widget.
3. **Every screen is a View + Controller + Binding triplet**, registered in `core/routes/app_pages.dart`. No exceptions unless the screen has zero mutable state (a couple of static confirmation screens use a plain `StatelessWidget` instead — that's a deliberate, documented choice, not a shortcut to copy blindly).
4. **`flutter analyze` must return zero issues, and `flutter test` must pass**, before considering any change finished. This has been the bar for every phase of this project so far.
5. **File and class naming**: files are `snake_case.dart`, classes are `PascalCase` matching the file name (`home_controller.dart` → `HomeController`). Routes are `Routes.camelCaseName` string constants.

---

**Developed by Moazam Samoo**
