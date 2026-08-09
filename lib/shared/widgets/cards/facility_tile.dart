import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum FacilityTileStyle { read, select }

class FacilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final FacilityTileStyle style;
  final bool isSelected;
  final VoidCallback? onTap;

  const FacilityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.style = FacilityTileStyle.read,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelectMode = style == FacilityTileStyle.select;
    final Color bgColor = isSelectMode && isSelected
        ? AppColors.primaryContainer
        : AppColors.background;
    final Color borderColor = isSelectMode && isSelected
        ? AppColors.primary
        : AppColors.border;

    return InkWell(
      onTap: isSelectMode ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelectMode && isSelected ? AppColors.primary : AppColors.surfaceTonal,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelectMode && isSelected ? AppColors.background : AppColors.textPrimary,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
