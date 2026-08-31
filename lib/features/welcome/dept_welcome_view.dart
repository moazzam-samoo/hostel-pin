import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dept_welcome_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/buttons/primary_button.dart';

class DeptWelcomeView extends GetView<DeptWelcomeController> {
  const DeptWelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background department building image — covers lower ~75%, edge-to-edge
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Image.asset(
              AppAssets.deptImg,
              fit: BoxFit.cover,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
            ),
          ),
          // Very subtle bottom fade so the Continue button is readable
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 100.h,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Foreground Header & Action Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  // IMCS Logo
                  Image.asset(
                    AppAssets.imcsLogo,
                    width: 140.w,
                    height: 140.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 8.h),
                  // Title: HostelPin App
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: AppStrings.appName,
                          style: AppTextStyles.authTitle.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 28.sp,
                          ),
                        ),
                        TextSpan(
                          text: ' App',
                          style: AppTextStyles.authTitle.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 28.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Subtitle: Developed By IMCS Students
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                      ),
                      children: const [
                        TextSpan(
                          text: AppStrings.developedBy,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: AppStrings.imcsStudents,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Continue Button
                  PrimaryButton(
                    text: AppStrings.continueButton,
                    onPressed: controller.onContinue,
                    expand: true,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
