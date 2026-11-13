import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'owner_profile_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/layout/profile_header_block.dart';
import '../../../shared/widgets/layout/settings_row.dart';
import '../../student/profile/widgets/language_sheet.dart';

class OwnerProfileView extends GetView<OwnerProfileController> {
  const OwnerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.brand,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Obx(() => ProfileHeaderBlock(
                    name: controller.currentUser.value?.displayName ??
                        'Hostel Owner',
                    email: controller.currentUser.value?.email ?? '',
                    imageUrl: controller.currentUser.value?.photoUrl,
                    onEdit: controller.onEditAvatar,
                  )),
            ),
            SizedBox(height: AppSpacing.md),
            Center(
              child: InkWell(
                onTap: () => Get.toNamed(Routes.ownerEditProfile),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    AppStrings.editProfileButton,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // 1. Security & Privacy
            Text(
              AppStrings.securityPrivacySection,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            SettingsRow(
              icon: Icons.home_work_outlined,
              title: AppStrings.myHostels,
              subtitle: AppStrings.ownerProfileMyHostelsSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.navigateToMyHostels,
            ),
            SettingsRow(
              icon: Icons.settings,
              title: AppStrings.accountSettingsTitle,
              subtitle: AppStrings.accountSettingsSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.navigateToAccountSettings,
            ),
            SettingsRow(
              icon: Icons.lock_outline,
              title: AppStrings.changePasswordRowTitle,
              subtitle: AppStrings.changePasswordRowSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: () => Get.toNamed(Routes.changePassword),
            ),
            SettingsRow(
              icon: Icons.verified_user_outlined,
              title: AppStrings.verificationCenterTitle,
              subtitle: AppStrings.verificationCenterSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.navigateToVerificationCenter,
            ),

            SizedBox(height: AppSpacing.lg),

            // 2. App Preferences
            Text(
              AppStrings.appPreferencesSection,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            const SettingsRow(
              icon: Icons.nightlight_round,
              title: AppStrings.darkModeTitle,
              subtitle:
                  '${AppStrings.darkModeSubtitle}${AppStrings.comingSoonSuffix}',
              trailing: SettingsRowTrailing.toggle,
              toggleValue: false,
              onToggleChanged: null,
            ),
            Obx(() => SettingsRow(
                  icon: Icons.notifications,
                  title: AppStrings.notificationsTitle,
                  subtitle: AppStrings.notificationsSubtitle,
                  trailing: SettingsRowTrailing.toggle,
                  toggleValue: controller.notificationsEnabled,
                  onToggleChanged: (_) => controller.toggleNotifications(),
                )),
            SettingsRow(
              icon: Icons.language,
              title: AppStrings.languageSelectionTitle,
              subtitle: AppStrings.languageSelectionValue,
              trailing: SettingsRowTrailing.none,
              onTap: () => showLanguageSheet(),
            ),

            SizedBox(height: AppSpacing.lg),

            // 3. Logout
            SettingsRow(
              icon: Icons.logout,
              title: AppStrings.logoutTitle,
              subtitle: AppStrings.logoutSubtitle,
              trailing: SettingsRowTrailing.chevron,
              isDestructive: true,
              onTap: controller.logout,
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
