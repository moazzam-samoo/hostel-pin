import 'package:flutter/material.dart';
import '../../core/constants/legal_content.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/navigation/app_top_bar.dart';

/// Read-only legal document (Privacy Policy / Terms of Service). Plain
/// content screen with no mutable state, so a controller-less
/// StatelessWidget, same precedent as SettingsView/CheckEmailView.
class LegalView extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const LegalView({super.key, required this.title, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(variant: AppTopBarVariant.titled, title: title),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.gutter),
          children: [
            Text(
              LegalContent.lastUpdated,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.md),
            for (final section in sections) ...[
              Text(section.title, style: AppTextStyles.cardTitle),
              SizedBox(height: AppSpacing.xs),
              for (final paragraph in section.paragraphs)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    paragraph,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ),
              SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
