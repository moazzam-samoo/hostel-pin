import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/layout/profile_header_block.dart';
import '../../../shared/widgets/layout/form_section_header.dart';
import '../../../shared/widgets/layout/settings_row.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import 'widgets/language_sheet.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.profileScreenTitle,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => ProfileHeaderBlock(
              name: controller.user?.displayName ?? '',
              email: controller.user?.email ?? '',
              imageUrl: controller.user?.photoUrl,
            )),
            SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: AppStrings.editProfileButton,
              onPressed: controller.onEditProfile,
            ),
            SizedBox(height: AppSpacing.xl),

            // Order per I11: Account/Security → App Preferences → Logout
            // (same order on both the student and owner profile screens).
            const FormSectionHeader(title: AppStrings.securityPrivacySection),
            SizedBox(height: AppSpacing.md),
            SettingsRow(
              icon: Icons.manage_accounts,
              title: AppStrings.accountSettingsTitle,
              subtitle: AppStrings.accountSettingsSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.onAccountSettings,
            ),
            Obx(() => SettingsRow(
              icon: Icons.bookmark,
              title: AppStrings.savedHostelsTitle,
              subtitle: AppStrings.savedHostelsSubtitle(controller.savedCount),
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.onSavedHostels,
            )),
            SettingsRow(
              icon: Icons.lock,
              title: AppStrings.changePasswordRowTitle,
              subtitle: AppStrings.changePasswordRowSubtitle,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.onChangePassword,
            ),
            SettingsRow(
              icon: Icons.privacy_tip,
              title: AppStrings.privacySettingsTitle,
              subtitle: AppStrings.controlProfile,
              trailing: SettingsRowTrailing.chevron,
              onTap: controller.onPrivacySettings,
            ),

            SizedBox(height: AppSpacing.xl),
            const FormSectionHeader(title: AppStrings.appPreferencesSection),
            SizedBox(height: AppSpacing.md),
            // No dark theme exists yet (I17) — shown disabled with a
            // "Coming soon" suffix rather than a live toggle that does
            // nothing when flipped.
            const SettingsRow(
              icon: Icons.dark_mode,
              title: AppStrings.darkModeTitle,
              subtitle: '${AppStrings.darkModeSubtitle}${AppStrings.comingSoonSuffix}',
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
              trailing: SettingsRowTrailing.chevron,
              onTap: () => showLanguageSheet(),
            ),

            SizedBox(height: AppSpacing.xl),
            SettingsRow(
              icon: Icons.logout,
              title: AppStrings.logoutTitle,
              subtitle: AppStrings.logoutSubtitle,
              trailing: SettingsRowTrailing.none,
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
