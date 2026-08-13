import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.gutter),
        child: Text(
          AppStrings.privacyPlaceholder,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
