import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/constants/app_strings.dart';
import 'package:hostel_finder_app/core/enums/user_role.dart';
import 'package:hostel_finder_app/core/enums/verification_status.dart';
import 'package:hostel_finder_app/core/routes/app_routes.dart';
import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/data/models/user_model.dart';
import 'package:hostel_finder_app/data/repositories/activity_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/repositories/verification_repository.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_controller.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_view.dart';
import 'package:hostel_finder_app/features/owner/shell/owner_shell_controller.dart';

class _FakeSession extends SessionService {
  @override
  void wireAuthState() {}
}

late FakeFirebaseFirestore db;

Future<void> _pump(WidgetTester tester,
    {VerificationStatus status = VerificationStatus.unverified}) async {
  final s = Get.find<SessionService>() as _FakeSession;
  s.currentUser.value = UserModel(
    uid: 'o1',
    displayName: 'Shumaila',
    email: 's@x.com',
    role: UserRole.owner,
    verificationStatus: status,
  );
  Get.put(OwnerShellController());
  Get.put(DashboardController());
  tester.view.physicalSize = const Size(375, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      theme: AppTheme.light,
      home: const DashboardView(),
      getPages: [
        GetPage(
            name: Routes.ownerVerification,
            page: () => const Scaffold(body: Text('VERIFICATION SCREEN'))),
      ],
    ),
  ));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() {
    Get.reset();
    db = FakeFirebaseFirestore();
    Get.put(HostelRepository(firestore: db));
    Get.put(ActivityRepository(firestore: db));
    Get.put(VerificationRepository(firestore: db));
    Get.put<SessionService>(_FakeSession());
  });

  testWidgets('a brand-new owner is asked to start verification, not told it is pending',
      (tester) async {
    await _pump(tester);
    expect(find.text(AppStrings.pendingVerificationTitle), findsNothing);
    expect(find.text(AppStrings.verifyAccountTitle), findsOneWidget);
    expect(find.text(AppStrings.addTabGateButton), findsOneWidget);
  });

  testWidgets('Start Verification opens the verification screen', (tester) async {
    await _pump(tester);
    await tester.tap(find.text(AppStrings.addTabGateButton));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('VERIFICATION SCREEN'), findsOneWidget);
  });

  testWidgets('a draft (not submitted) verification still asks to start', (tester) async {
    await db.collection('verifications').doc('o1').set({'status': 'draft'});
    await _pump(tester);
    expect(find.text(AppStrings.verifyAccountTitle), findsOneWidget);
    expect(find.text(AppStrings.pendingVerificationTitle), findsNothing);
  });

  testWidgets('a submitted verification with no hostel says it is under review',
      (tester) async {
    await db.collection('verifications').doc('o1').set({'status': 'pending'});
    await _pump(tester);
    expect(find.text(AppStrings.pendingVerificationTitle), findsOneWidget);
    expect(find.text(AppStrings.verificationUnderReviewMessage), findsOneWidget);
    expect(find.text(AppStrings.verifyAccountTitle), findsNothing);
  });

  testWidgets('a submitted verification names the hostel that is in review',
      (tester) async {
    await db.collection('verifications').doc('o1').set({'status': 'pending'});
    await db.collection('hostels').doc('1').set({
      'ownerId': 'o1', 'name': 'Sunrise', 'status': 'pending',
      'city': 'C', 'pricePerMonth': 10,
    });
    await _pump(tester);
    expect(find.text(AppStrings.pendingVerificationMessage('Sunrise')), findsOneWidget);
  });

  testWidgets('a rejected verification says so and offers to resubmit', (tester) async {
    await db.collection('verifications').doc('o1').set({'status': 'rejected'});
    await _pump(tester, status: VerificationStatus.rejected);
    expect(find.text(AppStrings.verificationRejectedTitle), findsOneWidget);
    expect(find.text(AppStrings.pendingVerificationTitle), findsNothing);
  });

  testWidgets('a verified owner sees no verification alert at all', (tester) async {
    await _pump(tester, status: VerificationStatus.verified);
    expect(find.text(AppStrings.pendingVerificationTitle), findsNothing);
    expect(find.text(AppStrings.verifyAccountTitle), findsNothing);
    expect(find.text(AppStrings.verificationRejectedTitle), findsNothing);
  });
}
