# Hostel Finder

A Flutter marketplace app that connects **students** searching for a place to live with **hostel owners** listing their properties — think a lightweight, purpose-built alternative to browsing classifieds for student housing.

**Developed by Moazam Samoo**

---

## Status

🟢 **Student role — UI complete, running on mock data.** Onboarding, authentication, and every student-facing screen (Home, Map, Hostel Detail, Saved, Search & Filter, Profile) are built and navigable end to end.
🔴 **Owner role — not started.** Backend is not started.

In short: you can install the app, sign up, pick "Student," and browse a fully designed app backed by realistic mock data. Nothing is wired to a real server yet — see [Project status](#project-status-in-detail) below for exactly what that means.

---

## Tech stack

| | |
|---|---|
| Framework | Flutter (Dart) |
| State management | [GetX](https://pub.dev/packages/get) — state, routing, and dependency injection |
| Architecture | MVVM (Model – View – ViewModel/Controller), strictly separated |
| Design scaling | `flutter_screenutil`, designed against a 375×812 baseline |
| Maps | `google_maps_flutter` + `geolocator` |
| Images | `cached_network_image` (network) / `Image.asset` (local), auto-detected |
| — see [Project status](#project-status-in-detail) |

---

## Getting started

```bash
flutter pub get
flutter run
```

No environment variables, API keys, or backend setup are required to run the app today — every screen is backed by mock data (see `lib/data/mock/`). A Google Maps API key will be needed once the Map tab is expected to render real map tiles on a physical device/emulator (add it to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`).

Run the test suite:
```bash
flutter test
```

Check for lint/analysis issues:
```bash
flutter analyze
```

---

## Project structure

```
lib/
├── app.dart, main.dart        # App entry point, theme, routing bootstrap
├── core/                      # Design tokens, routes, enums, utils — shared across the whole app
├── data/                      # Models, mock data, and MockDataService (today's stand-in for a backend)
├── features/                  # One folder per screen/flow (splash, welcome, auth, role_selection, student, owner)
└── shared/                    # Reusable widgets used across every screen (buttons, cards, inputs, layout, ...)
```

See **`GUIDANCE.md`** in this folder for the full, detailed folder tree and an explanation of how state management and navigation are wired together.

---

## Project status, in detail

This app was built in phases; each phase has a written plan and a written record of what was actually verified against the code (not just claimed). If you're picking this project back up, start with `GUIDANCE.md`, then these, in the repo root (one level up from this file):


**Completed:**
- Foundation: design tokens (colors, typography, spacing, radii), 54 reusable shared widgets
- Full authentication flow: Splash → Welcome → Login/Signup → Role Selection → Change Password, all UI-complete with mocked (simulated) network calls
- Full student flow: Home, Map, Hostel Detail, Saved, Search & Filter, Profile (+ Edit Profile / Settings / Privacy / Language)

**Not started:**
- Owner role screens (dashboard, listings, add-listing form)
- Real backend: Not conneded yet
- Push notifications, real-time data, payments — none of these are in scope yet

Every screen you can currently reach is real, navigable UI — it just reads from and writes to an in-memory mock data service (`lib/data/services/mock_data_service.dart`) instead of a live backend.

---

**Developed by Moazam Samoo**
