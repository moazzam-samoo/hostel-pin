import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

const List<String> _languages = ['English(US)'];

void showLanguageSheet() {
  Get.bottomSheet(
    _LanguageSheetContent(),
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _LanguageSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.languageSheetTitle,
                style: AppTextStyles.sectionHeader),
            SizedBox(height: AppSpacing.md),
            // Only one language exists today — a real picker lands once
            // localization is added. Shown as selected, not interactive.
            ..._languages.map(
              (language) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(language, style: AppTextStyles.body),
                trailing: const Icon(Icons.check, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
