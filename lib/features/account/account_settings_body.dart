import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/layout/settings_row.dart';
import 'account_controller.dart';

/// The rows shared by the student and owner Account Settings screens:
/// Privacy Policy, Terms of Service, and Delete Account.
class AccountSettingsBody extends GetView<AccountController> {
  const AccountSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          ListView(
            padding: EdgeInsets.all(AppSpacing.gutter),
            children: [
              SettingsRow(
                icon: Icons.shield_outlined,
                title: AppStrings.privacyPolicyTitle,
                onTap: controller.openPrivacyPolicy,
              ),
              SettingsRow(
                icon: Icons.description_outlined,
                title: AppStrings.termsTitle,
                onTap: controller.openTerms,
              ),
              SizedBox(height: AppSpacing.lg),
              SettingsRow(
                icon: Icons.delete_outline,
                title: AppStrings.deleteAccountTitle,
                subtitle: AppStrings.deleteAccountSubtitle,
                isDestructive: true,
                onTap:
                    controller.isDeleting.value ? null : controller.requestDeleteAccount,
              ),
            ],
          ),
          if (controller.isDeleting.value)
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.textPrimary.withValues(alpha: 0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.background),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
