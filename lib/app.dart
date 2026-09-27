import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

class HostelFinderApp extends StatelessWidget {
  const HostelFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light, // Default to light theme as requested
      initialBinding: InitialBinding(),
      // The web build only ever serves the admin panel — nothing else
      // under features/ is designed for desktop web, so skip the mobile
      // splash/onboarding flow entirely on web and go straight to the
      // admin login gate. AdminMiddleware handles the signed-in-already case.
      initialRoute: kIsWeb ? Routes.adminLogin : Routes.splash,
      getPages: AppPages.pages,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: child!,
        );
      },
    );
  }
}
