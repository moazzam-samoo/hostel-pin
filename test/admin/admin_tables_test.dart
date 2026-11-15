import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/repositories/user_repository.dart';
import 'package:hostel_finder_app/features/admin/hostels/admin_hostels_controller.dart';
import 'package:hostel_finder_app/features/admin/hostels/admin_hostels_view.dart';
import 'package:hostel_finder_app/features/admin/users/admin_users_controller.dart';
import 'package:hostel_finder_app/features/admin/users/admin_users_view.dart';

Future<void> _pump(WidgetTester tester, Widget child, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(1440, 900),
    builder: (context, _) => GetMaterialApp(
      home: Scaffold(body: child),
    ),
  ));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

const _sizes = <String, Size>{
  'desktop 1440x900': Size(1440, 900),
  'laptop 1024x768': Size(1024, 768),
  'tablet 800x1000': Size(800, 1000),
};

void main() {
  setUp(() => Get.reset());

  for (final e in _sizes.entries) {
    testWidgets('Users table with rows renders without exceptions at ${e.key}',
        (tester) async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('s1').set({
        'role': 'student', 'displayName': 'Sara', 'email': 's@x.com', 'status': 'active',
      });
      Get.put(UserRepository(firestore: db));
      Get.put(AdminUsersController());
      await _pump(tester, const AdminUsersView(), e.value);
      expect(find.text('Sara'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Hostels table with rows renders without exceptions at ${e.key}',
        (tester) async {
      final db = FakeFirebaseFirestore();
      await db.collection('hostels').doc('1').set({
        'ownerId': 'o1', 'name': 'Sunrise', 'status': 'pending',
        'city': 'Hyderabad', 'pricePerMonth': 1000,
      });
      Get.put(HostelRepository(firestore: db));
      Get.put(AdminHostelsController());
      await _pump(tester, const AdminHostelsView(), e.value);
      expect(find.text('Sunrise'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
