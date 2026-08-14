import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StatRowTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? tileColor;
  final Color? iconColor;
  final Widget? trailing;

  const StatRowTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.tileColor,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tileColor ?? AppColors.background,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.gutter),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTonal,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.sectionHeader.copyWith(fontSize: 18),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
