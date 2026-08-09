import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/role_selection_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../core/theme/app_radius.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      applyGutter: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.chooseRoleTitle,
              style: AppTextStyles.authTitle.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.chooseRoleSubtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            
            Expanded(
              child: ListView(
                children: [
                  const _RoleCard(
                    role: UserRole.student,
                    title: 'Student',
                    subtitle: 'Find and book the perfect hostel for your studies',
                    icon: Icons.school_outlined,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  const _RoleCard(
                    role: UserRole.owner,
                    title: 'Hostel Owner',
                    subtitle: 'List your property and manage bookings easily',
                    icon: Icons.business_outlined,
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Obx(
                () => PrimaryButton(text: AppStrings.continueButton, onPressed: controller.confirmRole,
                      isDisabled: controller.selectedRole.value == null,
                  expand: true,
                  isLoading: controller.isLoading.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends GetView<RoleSelectionController> {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedRole.value == role;
      
      return GestureDetector(
        onTap: () => controller.selectRole(role),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.authCard),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 32,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary)
            ],
          ),
        ),
      );
    });
  }
}
