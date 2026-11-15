import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_sizes.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.logoWithName,
              width: AppSizes.brandLogo,
              height: AppSizes.brandLogo,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
