import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/constants/app_strings.dart';
import 'package:hostel_finder_app/core/enums/user_role.dart';
import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/data/models/user_model.dart';
import 'package:hostel_finder_app/data/repositories/activity_repository.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_controller.dart';
import 'package:hostel_finder_app/features/owner/dashboard/dashboard_view.dart';

class _FakeSessionService extends SessionService {
  @override
  void wireAuthState() {}
}

UserModel _user(String name, {String email = 'a.b@x.com'}) =>
    UserModel(uid: 'o1', displayName: name, email: email, role: UserRole.owner);

late SessionService session;

void main() {
  setUp(() {
    Get.reset();
    final db = FakeFirebaseFirestore();
    Get.put(HostelRepository(firestore: db));
    Get.put(ActivityRepository(firestore: db));
    session = _FakeSessionService();
    Get.put<SessionService>(session);
  });

  test('welcomeName returns the display name', () {
    session.currentUser.value = _user('Ali Khan');
    expect(DashboardController().welcomeName, 'Ali Khan');
  });

  test('welcomeName falls back to the email prefix when the name is blank', () {
    session.currentUser.value = _user('  ');
    expect(DashboardController().welcomeName, 'a.b');
  });

  test('welcomeName is empty when there is no user', () {
    expect(DashboardController().welcomeName, '');
  });

  test('dashboardWelcome formats with and without a name', () {
    expect(AppStrings.dashboardWelcome('Ali'), 'Welcome, Ali');
    expect(AppStrings.dashboardWelcome(''), 'Welcome');
  });

  testWidgets('the dashboard header says Welcome, <name>', (tester) async {
    session.currentUser.value = _user('Ali');
    Get.put(DashboardController());
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        theme: AppTheme.light,
        home: const DashboardView(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Welcome, Ali'), findsOneWidget);
  });
}
