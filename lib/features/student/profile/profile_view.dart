import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'profile_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/layout/profile_header_block.dart';
import '../../../shared/widgets/layout/settings_row.dart';
import 'widgets/language_sheet.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

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
                    name: controller.user?.displayName ?? 'Usaid Khan',
                    email:
                        controller.user?.email ?? 'usaidKhanChandio@gmail.com',
                    imageUrl: controller.user?.photoUrl,
                    onEdit: controller.onEditAvatar,
                  )),
            ),
            SizedBox(height: AppSpacing.md),
            Center(
              child: InkWell(
                onTap: controller.onEditProfile,
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
              icon: Icons.settings,
              title: AppStrings.accountSettingsTitle,
              subtitle: AppStrings.accountSettingsSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.onAccountSettings,
            ),
            Obx(() => SettingsRow(
                  icon: Icons.favorite_border,
                  title: AppStrings.savedHostelsTitle,
                  subtitle:
                      AppStrings.savedHostelsSubtitle(controller.savedCount.value),
                  trailing: SettingsRowTrailing.chevron,
                  onTap: controller.onSavedHostels,
                )),
            SettingsRow(
              icon: Icons.lock_outline,
              title: AppStrings.changePasswordRowTitle,
              subtitle: AppStrings.changePasswordRowSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.onChangePassword,
            ),
            SettingsRow(
              icon: Icons.shield_outlined,
              title: AppStrings.privacySettingsTitle,
              subtitle: AppStrings.controlProfile,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.onPrivacySettings,
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
                  toggleValue: controller.notificationsEnabled.value,
                  onToggleChanged: controller.toggleNotifications,
                )),
            SettingsRow(
              icon: Icons.language,
              title: AppStrings.languageSelectionTitle,
              subtitle: AppStrings.languageSelectionValue,
              trailing: SettingsRowTrailing.none,
              onTap: () => showLanguageSheet(),
            ),
            SettingsRow(
              icon: Icons.logout,
              title: AppStrings.logoutTitle,
              subtitle: AppStrings.logoutSubtitle,
              trailing: SettingsRowTrailing.chevron,
              isDestructive: true,
              onTap: controller.onLogout,
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
