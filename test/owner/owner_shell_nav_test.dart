import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/enums/user_role.dart';
import 'package:hostel_finder_app/core/enums/verification_status.dart';
import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/data/models/user_model.dart';
import 'package:hostel_finder_app/data/repositories/activity_repository.dart';
import 'package:hostel_finder_app/data/repositories/auth_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/repositories/user_repository.dart';
import 'package:hostel_finder_app/data/repositories/verification_repository.dart';
import 'package:hostel_finder_app/data/services/auth_service.dart';
import 'package:hostel_finder_app/data/services/cloudinary_service.dart';
import 'package:hostel_finder_app/data/services/location_service.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/data/services/storage_service.dart';
import 'package:hostel_finder_app/features/owner/shell/owner_shell_binding.dart';
import 'package:hostel_finder_app/features/owner/shell/owner_shell_controller.dart';
import 'package:hostel_finder_app/features/owner/shell/owner_shell_view.dart';

class _FakeSessionService extends SessionService {
  @override
  void wireAuthState() {}
}

late FakeFirebaseFirestore db;

const _owner = UserModel(
  uid: 'o1',
  displayName: 'Ali Owner',
  email: 'ali@example.com',
  role: UserRole.owner,
  verificationStatus: VerificationStatus.unverified,
);

Future<void> _pumpApp(WidgetTester tester) async {
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
        initialRoute: '/start',
        getPages: [
          GetPage(name: '/start', page: () => const Scaffold(body: Text('START'))),
          GetPage(name: '/wizard', page: () => const Scaffold(body: Text('WIZARD'))),
          GetPage(
            name: '/shell',
            page: () => const OwnerShellView(),
            binding: OwnerShellBinding(),
          ),
        ],
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Taps each tab icon and checks the PageView really moved to that page.
Future<void> _expectEveryTabWorks(WidgetTester tester) async {
  final shell = Get.find<OwnerShellController>();
  final tabs = <IconData, int>{
    Icons.apartment_rounded: 1,
    Icons.add_circle_outline_rounded: 2,
    Icons.person_rounded: 3,
    Icons.grid_view_rounded: 0,
  };
  for (final entry in tabs.entries) {
    await tester.tap(find.byIcon(entry.key).last);
    await _settle(tester);
    expect(shell.currentIndex.value, entry.value, reason: 'index for ${entry.key}');
    expect(shell.pageController.page?.round(), entry.value,
        reason: 'the page must actually change for tab ${entry.value}');
    expect(tester.takeException(), isNull);
  }
}

void main() {
  setUp(() async {
    Get.reset();
    db = FakeFirebaseFirestore();
    Get.put(HostelRepository(firestore: db));
    Get.put(ActivityRepository(firestore: db));
    Get.put(VerificationRepository(firestore: db));
    Get.put(UserRepository(firestore: db));
    Get.put(StorageService());
    Get.put(LocationService());
    Get.put(CloudinaryService());
    Get.put(AuthService());
    Get.put(AuthRepository());
    final session = _FakeSessionService();
    Get.put<SessionService>(session);
    session.currentUser.value = _owner;
    await db.collection('verifications').doc('o1').set({'status': 'pending'});
  });

  testWidgets('tabs change pages on a freshly opened shell', (tester) async {
    await _pumpApp(tester);
    Get.offAllNamed('/shell');
    await _settle(tester);
    await _expectEveryTabWorks(tester);
  });

  testWidgets('tabs change pages after returning from the verification wizard '
      '(what the Done button now does)', (tester) async {
    await _pumpApp(tester);
    Get.offAllNamed('/shell');
    await _settle(tester);
    Get.toNamed('/wizard');
    await _settle(tester);
    expect(find.text('WIZARD'), findsOneWidget);
    Get.until((route) => route.settings.name == '/shell' || route.isFirst);
    await _settle(tester);
    await _expectEveryTabWorks(tester);
  });

  // Documents the bug: building the shell widget directly (no binding) leaves
  // the nav bar dead. Step 6's Done button must never do this.
  testWidgets('REGRESSION GUARD: step 6 does not build OwnerShellView directly',
      (tester) async {
    final src = File('lib/features/owner/verification/steps/step6_submission.dart')
        .readAsStringSync();
    expect(src.contains('OwnerShellView()'), isFalse);
    expect(src.contains('offAll'), isFalse);
    expect(src.contains('Get.until'), isTrue);
  });
}
