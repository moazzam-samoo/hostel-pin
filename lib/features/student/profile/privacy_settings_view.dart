import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/layout/settings_row.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';

class PrivacySettingsView extends StatelessWidget {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.privacySettingsTitle,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.gutter),
        children: [
          SettingsRow(
            icon: Icons.shield_outlined,
            title: AppStrings.privacyPolicyTitle,
            onTap: () => Get.toNamed(Routes.privacyPolicy),
          ),
          SettingsRow(
            icon: Icons.description_outlined,
            title: AppStrings.termsTitle,
            onTap: () => Get.toNamed(Routes.termsOfService),
          ),
        ],
      ),
    );
  }
}
