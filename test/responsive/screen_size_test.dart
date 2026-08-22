// Block D.5 — automated substitute for a manual RenderFlex-overflow device
// sweep. Pumps the 5 highest-risk real screens named in TASK-Phase-5.md
// (Add Listing, Owner Dashboard, Owner Listings, and Search's filter sheet;
// AppBottomNav is covered directly in test/widgets/shared_widgets_test.dart
// since it's a shared widget, not a screen) at each of 7 device sizes plus
// both 1.0x and 1.3x textScaler at the 375x812 baseline, asserting
// tester.takeException() is null after every pump/settle.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/data/services/mock_data_service.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/features/owner/add_listing/add_listing_controller.dart';
import 'package:hostel_finder_app/features/owner/add_listing/add_listing_view.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_controller.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_view.dart';
import 'package:hostel_finder_app/features/owner/listings/listings_controller.dart';
import 'package:hostel_finder_app/features/owner/listings/listings_view.dart';
import 'package:hostel_finder_app/features/student/search/search_controller.dart'
    as app_search;
import 'package:hostel_finder_app/features/student/search/search_view.dart';

/// The 6 explicit device sizes TASK-Phase-5.md's D.5 names, plus a 7th
/// (landscape rotation of the 375x812 baseline) to cover the "+ landscape"
/// half of D.5's own requirement.
const _sizes = <String, Size>{
  'iPhone SE (320x568)': Size(320, 568),
  'baseline (375x812)': Size(375, 812),
  'iPhone 11 (414x896)': Size(414, 896),
  'iPhone 13 Pro Max (428x926)': Size(428, 926),
  'iPad portrait (768x1024)': Size(768, 1024),
  'iPad Pro portrait (800x1280)': Size(800, 1280),
  'baseline landscape (812x375)': Size(812, 375),
};

/// Test double for SessionService — skips wireAuthState()'s real Firebase
/// calls (no Get.find<AuthService>()/UserRepository), leaving `currentUser`
/// as a plain, never-populated Rxn. Fine here: none of the screens under
/// test in this file assert on a specific signed-in identity, only that
/// they render without overflow/exceptions.
class _FakeSessionService extends SessionService {
  @override
  void wireAuthState() {}
}

Future<void> _pumpAtSize(
  WidgetTester tester,
  Size size,
  Widget child, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    await Get.putAsync(() => MockDataService().init(), permanent: true);
    Get.put<SessionService>(_FakeSessionService());
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
  });

  group('D.5 — Add Listing screen (largest form, most fields)', () {
    for (final entry in _sizes.entries) {
      testWidgets('renders with no RenderFlex overflow at ${entry.key}',
          (tester) async {
        Get.put(AddListingController());
        await _pumpAtSize(tester, entry.value, const AddListingView());
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at ${entry.key}');
      });
    }

    for (final scale in [1.0, 1.3]) {
      testWidgets('renders with no overflow at ${scale}x textScaler (baseline)',
          (tester) async {
        Get.put(AddListingController());
        await _pumpAtSize(tester, const Size(375, 812), const AddListingView(),
            textScale: scale);
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at textScale=$scale');
      });
    }
  });

  group('D.5 — Owner Dashboard screen (stat row, fixed-width trailing labels)',
      () {
    for (final entry in _sizes.entries) {
      testWidgets('renders with no RenderFlex overflow at ${entry.key}',
          (tester) async {
        Get.put(DashboardController());
        await _pumpAtSize(tester, entry.value, const DashboardView());
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at ${entry.key}');
      });
    }

    for (final scale in [1.0, 1.3]) {
      testWidgets('renders with no overflow at ${scale}x textScaler (baseline)',
          (tester) async {
        Get.put(DashboardController());
        await _pumpAtSize(tester, const Size(375, 812), const DashboardView(),
            textScale: scale);
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at textScale=$scale');
      });
    }
  });

  group('D.5 — Owner Listings screen (card + FacilityGrid + action row stack)',
      () {
    for (final entry in _sizes.entries) {
      testWidgets('renders with no RenderFlex overflow at ${entry.key}',
          (tester) async {
        Get.put(ListingsController());
        await _pumpAtSize(tester, entry.value, const ListingsView());
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at ${entry.key}');
      });
    }

    for (final scale in [1.0, 1.3]) {
      testWidgets('renders with no overflow at ${scale}x textScaler (baseline)',
          (tester) async {
        Get.put(ListingsController());
        await _pumpAtSize(tester, const Size(375, 812), const ListingsView(),
            textScale: scale);
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at textScale=$scale');
      });
    }
  });

  group(
      'D.5 — Search filter bottom sheet (RangeSlider + AmenitySelector + sort tiles)',
      () {
    for (final entry in _sizes.entries) {
      testWidgets('opens with no RenderFlex overflow at ${entry.key}',
          (tester) async {
        Get.put(app_search.SearchController());
        await _pumpAtSize(tester, entry.value, const SearchView());
        // Open the filter sheet the same way a real user does: tap the
        // tune icon in the results header.
        final tuneIcon = find.byIcon(Icons.tune);
        expect(tuneIcon, findsOneWidget);
        await tester.tap(tuneIcon);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at ${entry.key}');
      });
    }

    for (final scale in [1.0, 1.3]) {
      testWidgets('opens with no overflow at ${scale}x textScaler (baseline)',
          (tester) async {
        Get.put(app_search.SearchController());
        await _pumpAtSize(tester, const Size(375, 812), const SearchView(),
            textScale: scale);
        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: 'Overflow/exception at textScale=$scale');
      });
    }
  });
}
