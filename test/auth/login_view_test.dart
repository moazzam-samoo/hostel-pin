import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/enums/user_role.dart';
import 'package:hostel_finder_app/core/routes/app_routes.dart';
import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/data/repositories/auth_repository.dart';
import 'package:hostel_finder_app/data/repositories/user_repository.dart';
import 'package:hostel_finder_app/data/services/auth_service.dart';
import 'package:hostel_finder_app/features/auth/auth_controller.dart';
import 'package:hostel_finder_app/features/auth/controller/login_controller.dart';
import 'package:hostel_finder_app/features/auth/view/login_view.dart';

/// AuthRepository double: no Firebase, scripted Google result, records sign-outs.
class _FakeAuthRepository extends AuthRepository {
  GoogleSignInResolution? googleResult;
  int signOutCalls = 0;

  @override
  Future<GoogleSignInResolution?> signInWithGoogleAndResolveRole({
    required UserRole fallbackRole,
  }) async =>
      googleResult;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

late _FakeAuthRepository _authRepo;

Widget _app() {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginView(),
      getPages: [
        GetPage(name: Routes.privacyPolicy, page: () => const Scaffold(body: Text('PRIVACY PAGE'))),
        GetPage(name: Routes.termsOfService, page: () => const Scaffold(body: Text('TERMS PAGE'))),
        GetPage(name: Routes.studentShell, page: () => const Scaffold(body: Text('STUDENT SHELL'))),
        GetPage(name: Routes.ownerShell, page: () => const Scaffold(body: Text('OWNER SHELL'))),
      ],
    ),
  );
}

Future<void> _pump(WidgetTester tester, Size size, {double textScale = 1.0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(_app());
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    Get.reset();
    Get.put(AuthService());
    Get.put(UserRepository(firestore: FakeFirebaseFirestore()));
    _authRepo = _FakeAuthRepository();
    Get.put<AuthRepository>(_authRepo);
    Get.put(AuthController()).selectedRole.value = UserRole.student;
    Get.put(LoginController());
  });

  testWidgets('Login fits one screen at 375x812 (no scrolling needed)', (tester) async {
    await _pump(tester, const Size(375, 812));
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(scrollable.position.maxScrollExtent, 0,
        reason: 'the login form should not need scrolling on a standard phone');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login has no overflow on a small phone (320x568) and at 1.3x text', (tester) async {
    await _pump(tester, const Size(320, 568), textScale: 1.3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Google button is full width and as tall as the Login button', (tester) async {
    await _pump(tester, const Size(375, 812));
    final google = tester.getSize(find.text('Continue with Google').hitTestable().first);
    expect(google.width, greaterThan(0));
    final loginButton = tester.getSize(find.widgetWithText(ElevatedButton, 'Login'));
    final googleBox = tester.getSize(find.ancestor(
      of: find.text('Continue with Google'),
      matching: find.byType(Container),
    ).first);
    expect(googleBox.height, loginButton.height);
    expect(googleBox.width, loginButton.width);
  });

  testWidgets('Privacy Policy and Terms links open their pages', (tester) async {
    await _pump(tester, const Size(375, 812));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('PRIVACY PAGE'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(find.text('TERMS PAGE'), findsOneWidget);
  });

  testWidgets('Account type switch changes the selected role', (tester) async {
    await _pump(tester, const Size(375, 812));
    final auth = Get.find<AuthController>();
    expect(auth.selectedRole.value, UserRole.student);

    await tester.tap(find.text('Owner'));
    await tester.pump();
    expect(auth.selectedRole.value, UserRole.owner);

    await tester.tap(find.text('Student'));
    await tester.pump();
    expect(auth.selectedRole.value, UserRole.student);
  });

  testWidgets('Existing Owner account + Student selected: blocked with a clear message',
      (tester) async {
    await _pump(tester, const Size(375, 812));
    _authRepo.googleResult =
        const GoogleSignInResolution(role: UserRole.owner, isNewUser: false);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.textContaining('already has an Owner account'), findsOneWidget);
    expect(_authRepo.signOutCalls, 1);
    expect(find.text('OWNER SHELL'), findsNothing);
    expect(find.text('STUDENT SHELL'), findsNothing);
  });

  testWidgets('Matching role logs in normally', (tester) async {
    await _pump(tester, const Size(375, 812));
    Get.find<AuthController>().selectedRole.value = UserRole.owner;
    _authRepo.googleResult =
        const GoogleSignInResolution(role: UserRole.owner, isNewUser: false);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('OWNER SHELL'), findsOneWidget);
    expect(_authRepo.signOutCalls, 0);
  });

  testWidgets('A brand-new Google account is created as the selected type, not blocked',
      (tester) async {
    await _pump(tester, const Size(375, 812));
    Get.find<AuthController>().selectedRole.value = UserRole.owner;
    _authRepo.googleResult =
        const GoogleSignInResolution(role: UserRole.owner, isNewUser: true);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('OWNER SHELL'), findsOneWidget);
    expect(_authRepo.signOutCalls, 0);
  });
}
