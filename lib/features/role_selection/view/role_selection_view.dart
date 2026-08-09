import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/role_selection_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/widgets/layout/auth_hero_sheet.dart';
import '../widgets/role_option_block.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthHeroSheet(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter, vertical: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppStrings.welcome,
                  style: AppTextStyles.authTitle, textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.xs),
              Text(AppStrings.welcomeTo,
                  style: AppTextStyles.labelSentence,
                  textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.xl * 1.5),
              RoleOptionBlock(
                icon: Icons.school_outlined,
                sectionTitle: AppStrings.studentSectionTitle,
                descriptionTitle: AppStrings.studentDescriptionTitle,
                descriptionBody: AppStrings.studentDescriptionBody,
                ctaText: AppStrings.continueAsStudent,
                onTap: () => controller.selectRole(UserRole.student),
              ),
              SizedBox(height: AppSpacing.xl * 2),
              RoleOptionBlock(
                icon: Icons.vpn_key_outlined,
                sectionTitle: AppStrings.ownerSectionTitle,
                descriptionTitle: AppStrings.ownerDescriptionTitle,
                descriptionBody: AppStrings.ownerDescriptionBody,
                ctaText: AppStrings.continueAsOwner,
                onTap: () => controller.selectRole(UserRole.owner),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
