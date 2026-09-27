import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_settings_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class AdminSettingsView extends GetView<AdminSettingsController> {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.adminSettingsTitle, style: AppTextStyles.screenTitle),
          const SizedBox(height: 4),
          Text(AppStrings.adminSettingsSubtitle, style: AppTextStyles.screenSubtitle),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final config = controller.config.value;

              return ListView(
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 24),
                  Text(AppStrings.adminFeatureControlsTitle, style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 12),
                  // Global System's Default Language / System Timezone
                  // dropdowns (mockup, Settings.png) are deliberately not
                  // built here — Appendix C's frozen `config/appSettings`
                  // schema has no fields for either (Block H.3). Building
                  // dropdowns with nowhere real to persist to would look
                  // functional while silently doing nothing, the exact
                  // thing this project's own "AI Matched 92%" precedent
                  // warns against — flagged as a real product question
                  // instead, same discipline as the Dashboard's "Both"
                  // donut slice (Block D.3).
                  _buildSettingCard(
                    title: AppStrings.adminAllowNewSignupsTitle,
                    subtitle: AppStrings.adminAllowNewSignupsSubtitle,
                    value: config.allowNewSignups,
                    onChanged: controller.toggleAllowNewSignups,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    title: AppStrings.adminWhatsappIntegrationTitle,
                    subtitle: AppStrings.adminWhatsappIntegrationSubtitle,
                    value: config.whatsappIntegration,
                    onChanged: controller.toggleWhatsappIntegration,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    title: AppStrings.adminAutoApproveOwnersTitle,
                    subtitle: AppStrings.adminAutoApproveOwnersSubtitle,
                    value: config.autoApproveOwners,
                    onChanged: controller.toggleAutoApproveOwners,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    title: AppStrings.adminMaintenanceModeTitle,
                    subtitle: AppStrings.adminMaintenanceModeSubtitle,
                    value: config.maintenanceMode,
                    onChanged: controller.toggleMaintenanceMode,
                    destructive: true,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Obx(() {
      final admin = controller.currentAdmin;
      return Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: (admin?.photoUrl != null && admin!.photoUrl!.isNotEmpty)
                    ? NetworkImage(admin.photoUrl!)
                    : null,
                child: (admin?.photoUrl == null || admin!.photoUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(admin?.displayName ?? '', style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Text(
                admin?.email ?? '',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 180,
                child: PrimaryButton(
                  text: AppStrings.adminEditProfileButton,
                  onPressed: () => _showEditProfileDialog(context, admin?.displayName ?? ''),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.dialog)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.adminEditProfileDialogTitle, style: AppTextStyles.sectionHeader),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameController,
                hintText: AppStrings.editProfileNameLabel,
                leadingIcon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              Obx(() => PrimaryButton(
                    text: AppStrings.adminSaveButton,
                    isLoading: controller.isSavingProfile.value,
                    onPressed: () => controller.saveDisplayName(nameController.text),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool destructive = false,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: destructive ? AppColors.error.withAlpha(60) : AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SwitchListTile(
          title: Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(color: destructive ? AppColors.error : AppColors.textPrimary),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ),
          value: value,
          activeThumbColor: destructive ? AppColors.error : AppColors.primary,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
