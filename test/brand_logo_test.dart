import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/constants/app_assets.dart';
import 'package:hostel_finder_app/core/constants/app_strings.dart';
import 'package:hostel_finder_app/core/theme/app_theme.dart';
import 'package:hostel_finder_app/features/splash/splash_controller.dart';
import 'package:hostel_finder_app/features/splash/splash_view.dart';
import 'package:hostel_finder_app/features/welcome/welcome_controller.dart';
import 'package:hostel_finder_app/features/welcome/welcome_view.dart';

class _StubSplash extends SplashController {
  @override
  void onInit() {}
}

class _StubWelcome extends WelcomeController {
  @override
  void onInit() {}
}

bool _usesLogo(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .any((i) => i.image is AssetImage && (i.image as AssetImage).assetName == AppAssets.logoWithName);

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(theme: AppTheme.light, home: home),
  ));
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  setUp(() => Get.reset());

  test('the logo asset constant points at logo_1.png', () {
    expect(AppAssets.logoWithName, 'assets/images/logo_1.png');
  });

  testWidgets('Splash shows the logo image and no separate app-name text',
      (tester) async {
    Get.put<SplashController>(_StubSplash());
    await _pump(tester, const SplashView());
    expect(_usesLogo(tester), isTrue);
    expect(find.text(AppStrings.appName), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Welcome (onboarding 1) shows the logo image and no separate app-name text',
      (tester) async {
    Get.put<WelcomeController>(_StubWelcome());
    await _pump(tester, const WelcomeView());
    expect(_usesLogo(tester), isTrue);
    expect(find.text(AppStrings.appName), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
