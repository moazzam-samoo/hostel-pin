// Block E — golden tests for the 5 widgets TASK-Phase-5.md's plan names:
// HostelCard, FacilityTile, PrimaryButton, AppTextField, AppBottomNav.
//
// Pinned to a single platform (TargetPlatform.android, via the MaterialApp
// wrapper below) per §5.C's own risk note, so these diffs aren't sensitive
// to font-rendering differences across dev machines/OSes. Real app fonts
// are loaded once for the whole test/ tree by test/flutter_test_config.dart
// (golden_toolkit's loadAppFonts()).
//
// First run (or after an intentional visual change) needs:
//   flutter test --update-goldens test/golden/shared_widgets_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/shared/widgets/buttons/primary_button.dart';
import 'package:hostel_finder_app/shared/widgets/cards/facility_tile.dart';
import 'package:hostel_finder_app/shared/widgets/cards/hostel_card.dart';
import 'package:hostel_finder_app/shared/widgets/inputs/app_text_field.dart';
import 'package:hostel_finder_app/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:hostel_finder_app/shared/widgets/navigation/nav_item.dart';

Widget _wrapper(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light.copyWith(platform: TargetPlatform.android),
        home: Material(child: child),
      ),
    );

void main() {
  testGoldens('HostelCard .featured golden', (tester) async {
    await tester.pumpWidgetBuilder(
      const HostelCard(
        id: 'g1',
        name: 'Golden Test Hostel',
        location: 'Model Town',
        price: 12000,
        rating: 4.5,
        // A real, on-disk bundled asset path (not '' / a network URL) —
        // avoids two problems found while writing this test: (1)
        // NetworkImageBox's Image.file(File('')) branch hangs indefinitely
        // under pumpAndSettle() in this environment (reproduced directly:
        // two separate `flutter test` runs both stalled forever on exactly
        // this widget); (2) `assets/images/placeholder_hostel.png` — the
        // path NetworkImageBox's own error fallback hardcodes, and what
        // AGENTS.md's asset listing claims exists — is NOT actually present
        // on disk (only app_logo.png is; verified directly). That's a real,
        // pre-existing discrepancy, out of TASK-Phase-5.md's scope to fix —
        // flagged here and in the phase report, not silently fixed.
        imageUrl: 'assets/images/app_logo.png',
        ownerName: 'Awais Khokhar',
        layout: HostelCardLayout.featured,
      ),
      wrapper: _wrapper,
      surfaceSize: const Size(260, 330),
    );
    await screenMatchesGolden(tester, 'hostel_card_featured');
  });

  testGoldens('FacilityTile .read golden', (tester) async {
    await tester.pumpWidgetBuilder(
      const FacilityTile(
        icon: Icons.wifi,
        title: 'Fast Wifi',
        subtitle: 'Gigabit Speed',
        style: FacilityTileStyle.read,
      ),
      wrapper: _wrapper,
      surfaceSize: const Size(165, 60),
    );
    await screenMatchesGolden(tester, 'facility_tile_read');
  });

  testGoldens('PrimaryButton golden', (tester) async {
    await tester.pumpWidgetBuilder(
      PrimaryButton(text: 'Publish Listing', onPressed: () {}),
      wrapper: _wrapper,
      surfaceSize: const Size(220, 60),
    );
    await screenMatchesGolden(tester, 'primary_button');
  });

  testGoldens('AppTextField golden', (tester) async {
    await tester.pumpWidgetBuilder(
      const AppTextField(
          hintText: 'Enter your email', leadingIcon: Icons.email),
      wrapper: _wrapper,
      surfaceSize: const Size(343, 70),
    );
    await screenMatchesGolden(tester, 'app_text_field');
  });

  testGoldens('AppBottomNav golden', (tester) async {
    await tester.pumpWidgetBuilder(
      AppBottomNav(
        currentIndex: 0,
        onTabSelected: (_) {},
        items: const [
          NavItem(icon: Icons.home, label: 'Home', route: ''),
          NavItem(icon: Icons.map_outlined, label: 'Map', route: ''),
          NavItem(icon: Icons.favorite_border, label: 'Saved', route: ''),
          NavItem(icon: Icons.person_outline, label: 'Profile', route: ''),
        ],
      ),
      wrapper: _wrapper,
      surfaceSize: const Size(375, 90),
    );
    await screenMatchesGolden(tester, 'app_bottom_nav');
  });
}
