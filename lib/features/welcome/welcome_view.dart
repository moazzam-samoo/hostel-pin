import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'welcome_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/buttons/primary_button.dart';
import '../../shared/widgets/media/confetti_dots.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // // Top band
          // Container(
          //   height: 45 + MediaQuery.of(context).padding.top,
          //   width: double.infinity,
          //   color: AppColors.primaryVariant,
          // ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background illustration
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    AppAssets.onboardingBg,
                    fit: BoxFit.cover,
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: AppSpacing.xl),
                      Text(
                        AppStrings.welcome,
                        style: AppTextStyles.authTitle.copyWith(
                            fontSize: 28.sp, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        AppStrings.welcomeTo,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      ConfettiDots(
                        child: Image.asset(
                          AppAssets.appLogo,
                          width: AppSizes.authLogo,
                          height: AppSizes.authLogo,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.authTitle.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      PrimaryButton(
                        text: AppStrings.continueButton,
                        onPressed: controller.onContinue,
                        expand: true,
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
