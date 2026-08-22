import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final Color bgColor = isSelectMode
        ? (isSelected ? AppColors.primaryContainer : AppColors.background)
        : AppColors.surfaceTonal;
    final Border? border = isSelectMode
        ? Border.all(color: isSelected ? AppColors.primary : AppColors.border)
        : null;

    final Color badgeColor = isSelectMode
        ? (isSelected ? AppColors.primary : AppColors.surfaceTonal)
        : AppColors.background;

    final Color iconColor = isSelectMode
        ? (isSelected ? AppColors.background : AppColors.textPrimary)
        : AppColors.primaryVariant;

    return InkWell(
      onTap: isSelectMode ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: border,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 13.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
