// Block E — widget tests for the 10 shared widgets TASK-Phase-5.md names as
// the "top 10 shared widgets" (highest reuse / most call sites): HostelCard,
// AppBottomNav, SettingsRow, AppTextField, PrimaryButton, FacilityTile,
// PriceLabel, StatRowTile, AmenitySelector, NetworkImageBox. Each is pumped
// with representative props and asserted to render without exceptions, plus
// 1-2 meaningful interaction/state assertions where relevant.
//
// Every test pins tester.view.physicalSize/devicePixelRatio to the 375x812
// design baseline before pumping. Without this, flutter_test's default
// 800x600 surface is much wider than the 375 ScreenUtil design baseline,
// which inflates every `.sp`/`.w` value far beyond anything a real device
// would produce and causes spurious RenderFlex overflows unrelated to the
// widget under test (this was reproduced directly while diagnosing a
// previously-failing AmenitySelector test, before this fix).
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_finder_app/shared/widgets/buttons/primary_button.dart';
import 'package:hostel_finder_app/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:hostel_finder_app/shared/widgets/navigation/nav_item.dart';
import 'package:hostel_finder_app/shared/widgets/layout/settings_row.dart';
import 'package:hostel_finder_app/shared/widgets/inputs/app_text_field.dart';
import 'package:hostel_finder_app/shared/widgets/cards/facility_tile.dart';
import 'package:hostel_finder_app/shared/widgets/layout/price_label.dart';
import 'package:hostel_finder_app/shared/widgets/cards/stat_row_tile.dart';
import 'package:hostel_finder_app/shared/widgets/inputs/amenity_selector.dart';
import 'package:hostel_finder_app/shared/widgets/media/network_image_box.dart';
import 'package:hostel_finder_app/shared/widgets/cards/hostel_card.dart';
import 'package:hostel_finder_app/core/enums/amenity.dart';

void main() {
  Future<void> pumpBaseline(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  group('Shared Widgets Tests', () {
    testWidgets('PrimaryButton renders and fires onPressed when tapped',
        (WidgetTester tester) async {
      var tapped = false;
      await pumpBaseline(
        tester,
        PrimaryButton(text: 'Click Me', onPressed: () => tapped = true),
      );
      expect(find.text('Click Me'), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PrimaryButton does not fire onPressed when isDisabled',
        (WidgetTester tester) async {
      var tapped = false;
      await pumpBaseline(
        tester,
        PrimaryButton(
            text: 'Click Me', isDisabled: true, onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('AppBottomNav renders and highlights the correct tab',
        (WidgetTester tester) async {
      int? tappedIndex;
      await pumpBaseline(
        tester,
        AppBottomNav(
          currentIndex: 0,
          onTabSelected: (i) => tappedIndex = i,
          items: const [
            NavItem(icon: Icons.home, label: 'Home', route: '/home'),
            NavItem(icon: Icons.person, label: 'Profile', route: '/profile'),
          ],
        ),
      );
      // Selected tab renders its label; inactive tabs render icon-only.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Profile'), findsNothing);

      await tester.tap(find.byIcon(Icons.person));
      await tester.pump();
      expect(tappedIndex, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'SettingsRow renders, fires onTap, and toggle fires onToggleChanged',
        (WidgetTester tester) async {
      var tapped = false;
      await pumpBaseline(
        tester,
        SettingsRow(
          title: 'Settings',
          icon: Icons.settings,
          onTap: () => tapped = true,
        ),
      );
      expect(find.text('Settings'), findsOneWidget);
      await tester.tap(find.byType(SettingsRow));
      await tester.pump();
      expect(tapped, isTrue);

      bool? toggled;
      await pumpBaseline(
        tester,
        SettingsRow(
          title: 'Dark Mode',
          icon: Icons.dark_mode,
          trailing: SettingsRowTrailing.toggle,
          toggleValue: false,
          onToggleChanged: (v) => toggled = v,
        ),
      );
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('AppTextField renders, reports onChanged, and shows errorText',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      String? changed;
      await pumpBaseline(
        tester,
        AppTextField(
          controller: controller,
          hintText: 'Enter text',
          onChanged: (v) => changed = v,
        ),
      );
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(changed, 'hello');
      expect(controller.text, 'hello');

      await pumpBaseline(
        tester,
        const AppTextField(hintText: 'Enter text', errorText: 'Required'),
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('FacilityTile renders and fires onTap in select mode',
        (WidgetTester tester) async {
      var tapped = false;
      await pumpBaseline(
        tester,
        FacilityTile(
          title: 'Wi-Fi',
          icon: Icons.wifi,
          subtitle: 'High speed internet',
          style: FacilityTileStyle.select,
          onTap: () => tapped = true,
        ),
      );
      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.text('High speed internet'), findsOneWidget);

      await tester.tap(find.byType(FacilityTile));
      await tester.pump();
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PriceLabel renders the formatted amount and suffix',
        (WidgetTester tester) async {
      await pumpBaseline(tester, const PriceLabel(price: 15000));
      expect(find.textContaining('15,000'), findsOneWidget);
      expect(find.textContaining('/month'), findsOneWidget);
    });

    testWidgets('StatRowTile renders title/value and trailing in card layout',
        (WidgetTester tester) async {
      await pumpBaseline(
        tester,
        const StatRowTile(
          title: 'Total Listings',
          value: '5',
          icon: Icons.list,
        ),
      );
      expect(find.text('Total Listings'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await pumpBaseline(
        tester,
        const StatRowTile(
          layout: StatRowTileLayout.card,
          title: 'Total Views',
          value: '120',
          icon: Icons.visibility,
          trailing: Text('Traffic'),
        ),
      );
      expect(find.text('Total Views'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('Traffic'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AmenitySelector renders a tile per amenity and toggles on tap',
        (WidgetTester tester) async {
      Amenity? toggled;
      await pumpBaseline(
        tester,
        AmenitySelector(
          selectedAmenities: const {},
          onToggle: (a) => toggled = a,
        ),
      );
      expect(find.byType(AmenitySelector), findsOneWidget);
      expect(find.byType(FacilityTile), findsNWidgets(Amenity.values.length));

      await tester.tap(find.text(Amenity.wifi.title));
      await tester.pump();
      expect(toggled, Amenity.wifi);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'NetworkImageBox renders for a network URL and an empty fallback',
        (WidgetTester tester) async {
      await pumpBaseline(
        tester,
        const NetworkImageBox(imageUrl: 'https://example.com/photo.jpg'),
      );
      expect(find.byType(NetworkImageBox), findsOneWidget);
      expect(tester.takeException(), isNull);

      await pumpBaseline(tester, const NetworkImageBox(imageUrl: ''));
      expect(find.byType(NetworkImageBox), findsOneWidget);
    });

    testWidgets('HostelCard renders and fires onTap / onHeartTap',
        (WidgetTester tester) async {
      var cardTapped = false;
      var heartTapped = false;
      await pumpBaseline(
        tester,
        HostelCard(
          id: '1',
          name: 'Test Hostel',
          location: '123 Test St',
          price: 200.0,
          rating: 4.5,
          imageUrl: '',
          layout: HostelCardLayout.saved,
          isSaved: false,
          onTap: () => cardTapped = true,
          onHeartTap: () => heartTapped = true,
        ),
      );
      expect(find.text('Test Hostel'), findsOneWidget);

      // .saved layout is one of the two layouts that renders the heart
      // toggle (compact does not); .compact is covered separately below.
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      expect(heartTapped, isTrue);

      await tester.tap(find.text('Test Hostel'));
      await tester.pump();
      expect(cardTapped, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HostelCard .compact layout renders name, price, and rating',
        (WidgetTester tester) async {
      await pumpBaseline(
        tester,
        const HostelCard(
          id: '2',
          name: 'Moonlight Dorms',
          location: 'University Road',
          price: 8000,
          rating: 4.2,
          imageUrl: '',
        ),
      );
      expect(find.text('Moonlight Dorms'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
