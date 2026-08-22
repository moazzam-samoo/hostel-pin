import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class RoleOptionBlock extends StatelessWidget {
  final IconData icon;
  final String sectionTitle;
  final String descriptionTitle;
  final String descriptionBody;
  final String ctaText;
  final VoidCallback onTap;

  const RoleOptionBlock({
    super.key,
    required this.icon,
    required this.sectionTitle,
    required this.descriptionTitle,
    required this.descriptionBody,
    required this.ctaText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.roleIcon,
          height: AppSizes.roleIcon,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.background, size: 44),
        ),
        SizedBox(height: AppSpacing.md),
        Text(sectionTitle,
            style: AppTextStyles.authTitle, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.xs),
        Text(descriptionTitle,
            style: AppTextStyles.cardTitle, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.xs),
        Text(descriptionBody,
            style: AppTextStyles.labelSentence, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ctaText,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              const Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}
