import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/role_selection_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/widgets/layout/auth_hero_sheet.dart';
import '../widgets/role_option_block.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryVariant,
      body: AuthHeroSheet(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),
              Text(
                AppStrings.welcome,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                AppStrings.welcomeTo,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              RoleOptionBlock(
                icon: Icons.school_outlined,
                sectionTitle: AppStrings.studentSectionTitle,
                descriptionTitle: AppStrings.studentDescriptionTitle,
                descriptionBody: AppStrings.studentDescriptionBody,
                ctaText: AppStrings.continueAsStudent,
                onTap: () => controller.selectRole(UserRole.student),
              ),
              SizedBox(height: 20.h),
              RoleOptionBlock(
                icon: Icons.vpn_key_outlined,
                sectionTitle: AppStrings.ownerSectionTitle,
                descriptionTitle: AppStrings.ownerDescriptionTitle,
                descriptionBody: AppStrings.ownerDescriptionBody,
                ctaText: AppStrings.continueAsOwner,
                onTap: () => controller.selectRole(UserRole.owner),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
