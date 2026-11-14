import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/enums/hostel_gender.dart';
import 'package:hostel_finder_app/core/theme/app_shadows.dart';
import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/repositories/saved_repository.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/features/student/home/home_controller.dart';
import 'package:hostel_finder_app/features/student/home/home_view.dart';
import 'package:hostel_finder_app/shared/widgets/cards/hostel_card.dart';

class _FakeSessionService extends SessionService {
  @override
  void wireAuthState() {}
}

late FakeFirebaseFirestore _db;

Future<void> _seed(String id, String name, {String? gender}) {
  return _db.collection('hostels').doc(id).set({
    'status': 'published',
    'name': name,
    'pricePerMonth': 12000,
    'city': 'Hyderabad',
    if (gender != null) 'gender': gender,
  });
}

/// Home has continuously animating widgets (carousel, spinners), so
/// pumpAndSettle never settles; advance time in fixed steps instead.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pump(WidgetTester tester,
    {Size size = const Size(375, 812), double textScale = 1.0}) async {
  // Created here (inside the test's fake-async zone), not in setUp, so its
  // Firestore stream is delivered when the test pumps time.
  Get.put(HomeController());
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeView(),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  setUp(() async {
    Get.reset();
    _db = FakeFirebaseFirestore();
    // Sorted newest-first by id: Boys B2, Girls G2, Boys B1, Girls G1, legacy.
    await _seed('1001', 'Legacy Hostel');
    await _seed('1002', 'Girls One', gender: 'girls');
    await _seed('1003', 'Boys One', gender: 'boys');
    await _seed('1004', 'Girls Two', gender: 'girls');
    await _seed('1005', 'Boys Two', gender: 'boys');
    Get.put<SessionService>(_FakeSessionService());
    Get.put(HostelRepository(firestore: _db));
    Get.put(SavedRepository(firestore: _db));
  });

  testWidgets('All shows every published hostel, including legacy ones',
      (tester) async {
    await _pump(tester);
    for (final name in [
      'Boys One',
      'Boys Two',
      'Girls One',
      'Girls Two',
      'Legacy Hostel'
    ]) {
      expect(find.text(name), findsWidgets, reason: name);
    }
  });

  testWidgets('tapping Boys shows only boys hostels', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Boys').first);
    await _settle(tester);

    expect(find.text('Boys One'), findsWidgets);
    expect(find.text('Boys Two'), findsWidgets);
    expect(find.text('Girls One'), findsNothing);
    expect(find.text('Girls Two'), findsNothing);
    expect(find.text('Legacy Hostel'), findsNothing,
        reason: 'hostels without a gender appear only under All');
  });

  testWidgets('Girls then All restores the full list', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Girls').first);
    await _settle(tester);
    expect(find.text('Boys One'), findsNothing);
    expect(find.text('Girls One'), findsWidgets);

    await tester.tap(find.text('All').first);
    await _settle(tester);
    expect(find.text('Boys One'), findsWidgets);
    expect(find.text('Girls One'), findsWidgets);
    expect(find.text('Legacy Hostel'), findsWidgets);
  });

  testWidgets(
      'a category with no hostels shows its own message and keeps the chips',
      (tester) async {
    // Remove every girls hostel.
    await _db.collection('hostels').doc('1002').delete();
    await _db.collection('hostels').doc('1004').delete();

    await _pump(tester);
    await tester.tap(find.text('Girls').first);
    await _settle(tester);

    expect(find.text('No Girls hostels yet'), findsOneWidget);
    // Chips are still there, so the user can switch back.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Boys'), findsOneWidget);
  });

  for (final entry in {
    'iPhone SE (320x568)': const Size(320, 568),
    'baseline (375x812)': const Size(375, 812),
    'wide phone (428x926)': const Size(428, 926),
    'tablet (800x1280)': const Size(800, 1280),
  }.entries) {
    testWidgets(
        'Home (chips + featured card) has no overflow at ${entry.key} and 1.3x text',
        (tester) async {
      await _pump(tester, size: entry.value, textScale: 1.3);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the controller remembers the selected category', (tester) async {
    await _pump(tester);
    final c = Get.find<HomeController>();
    expect(c.selectedGender.value, isNull);
    c.selectGender(HostelGender.girls);
    await _settle(tester);
    expect(c.selectedGender.value, HostelGender.girls);
    expect(
        c.regularHostels.every((h) => h.gender == HostelGender.girls), isTrue);
  });

  testWidgets('hostel cards are borderless with the soft shadow',
      (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: HostelCard(
              id: 'x',
              name: 'Soft Hostel',
              location: 'Hyderabad',
              price: 12000,
              rating: 4.3,
              imageUrl: '',
              surface: HostelCardSurface.tonal,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final decorated = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty);
    expect(decorated.border, isNull);
    expect(decorated.boxShadow, AppShadows.softCard);
    expect(find.text('Rs:12000'), findsOneWidget);
  });

  test('HostelGender parses only valid values', () {
    expect(HostelGender.tryParse('boys'), HostelGender.boys);
    expect(HostelGender.tryParse('girls'), HostelGender.girls);
    expect(HostelGender.tryParse('co-ed'), isNull);
    expect(HostelGender.tryParse(null), isNull);
  });
}
