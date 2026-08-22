// Block D.4 — RTL smoke test. TASK-Phase-5.md confirms RTL is genuinely
// untouched (`grep -rn "Directionality\|EdgeInsetsDirectional" lib` is zero
// hits everywhere) and that a real Directionality(textDirection: rtl,
// child: ...) wrap "will surface every hardcoded left/right EdgeInsets/
// Alignment at once; there is no shortcut to this via static analysis."
// This is that automated equivalent: pump representative screens/widgets
// under a forced RTL Directionality and assert no exceptions/overflow.
//
// This is explicitly a *smoke test*, not a full RTL readiness pass — it
// proves nothing crashes or overflows under RTL, not that every layout is
// visually mirror-correct. Per TASK-Phase-5.md's own scoping of D.4, the
// static hardcoded left/right hits below are reported, not fixed, here:
//
//   grep -rn "EdgeInsets\.only([^)]*\b(left|right)\s*:" lib   (7 hits)
//     image_upload_section.dart:50            margin: EdgeInsets.only(right: ...)
//     app_top_bar.dart:72                     padding: EdgeInsets.only(left: 8.0)
//     listings_view.dart:66                   padding: EdgeInsets.only(left: ..., right: ...)
//     auth_hero_sheet.dart:34                 padding: EdgeInsets.only(left: 16.0)
//     field_label.dart:28                     padding: EdgeInsets.only(bottom: ..., left: 4.0)
//     app_dropdown_field.dart:57               padding: EdgeInsets.only(top: 4, left: 16)
//     app_text_field.dart:60                  padding: EdgeInsets.only(top: 4, left: 16)
//
//   grep -rn "Alignment\.(centerLeft|centerRight|topLeft|topRight|...)" lib   (3 hits)
//     owner_listing_card.dart:45              alignment: Alignment.topRight
//     auth_hero_sheet.dart:32                 alignment: Alignment.centerLeft
//     login_view.dart:102                     alignment: Alignment.centerRight
//
// 10 hits total, none touched by this pass. A full RTL-readiness pass would
// need to convert these to EdgeInsetsDirectional/AlignmentDirectional and
// re-verify visually — out of scope for a smoke test.
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
import 'package:hostel_finder_app/shared/widgets/cards/hostel_card.dart';
import 'package:hostel_finder_app/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:hostel_finder_app/shared/widgets/navigation/nav_item.dart';
import 'package:hostel_finder_app/shared/widgets/layout/settings_row.dart';

/// Test double for SessionService — see screen_size_test.dart's copy of the
/// same fake for the full rationale (real AuthService/UserRepository touch
/// live Firebase singletons at construction, unavailable in a plain widget
/// test).
class _FakeSessionService extends SessionService {
  @override
  void wireAuthState() {}
}

Future<void> _pumpRtl(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: child,
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

  group('RTL smoke test — shared widgets', () {
    testWidgets('HostelCard renders under RTL with no exceptions',
        (tester) async {
      await _pumpRtl(
        tester,
        Material(
          child: HostelCard(
            id: '1',
            name: 'RTL Test Hostel',
            location: 'Somewhere',
            price: 12000,
            rating: 4.3,
            imageUrl: '',
            layout: HostelCardLayout.saved,
            onTap: () {},
            onHeartTap: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppBottomNav renders under RTL with no exceptions',
        (tester) async {
      await _pumpRtl(
        tester,
        Material(
          child: AppBottomNav(
            currentIndex: 1,
            onTabSelected: (_) {},
            items: const [
              NavItem(icon: Icons.home, label: 'Home', route: ''),
              NavItem(icon: Icons.map_outlined, label: 'Map', route: ''),
              NavItem(icon: Icons.favorite_border, label: 'Saved', route: ''),
              NavItem(icon: Icons.person_outline, label: 'Profile', route: ''),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('SettingsRow renders under RTL with no exceptions',
        (tester) async {
      await _pumpRtl(
        tester,
        Material(
          child: SettingsRow(
            title: 'Account Settings',
            subtitle: 'Manage your account',
            icon: Icons.settings,
            onTap: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('RTL smoke test — real screens', () {
    testWidgets('Add Listing screen renders under RTL with no exceptions',
        (tester) async {
      Get.put(AddListingController());
      await _pumpRtl(tester, const AddListingView());
      expect(tester.takeException(), isNull);
    });

    testWidgets('Owner Dashboard screen renders under RTL with no exceptions',
        (tester) async {
      Get.put(DashboardController());
      await _pumpRtl(tester, const DashboardView());
      expect(tester.takeException(), isNull);
    });

    testWidgets('Owner Listings screen renders under RTL with no exceptions',
        (tester) async {
      Get.put(ListingsController());
      await _pumpRtl(tester, const ListingsView());
      expect(tester.takeException(), isNull);
    });
  });
}
