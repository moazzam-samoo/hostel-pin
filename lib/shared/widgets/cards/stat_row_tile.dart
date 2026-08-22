import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum StatRowTileLayout {
  /// Full-width tinted row: icon circle, title, value, optional trailing —
  /// used e.g. in the widget gallery / list-style stat displays.
  row,

  /// Icon square badge + stacked title/value + trailing on the far right —
  /// used by the Owner Dashboard's two stat cards.
  card,
}

class StatRowTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? tileColor;
  final Color? iconColor;
  final Widget? trailing;
  final StatRowTileLayout layout;

  const StatRowTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.tileColor,
    this.iconColor,
    this.trailing,
    this.layout = StatRowTileLayout.row,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case StatRowTileLayout.card:
        return _buildCard();
      case StatRowTileLayout.row:
        return _buildRow();
    }
  }

  Widget _buildRow() {
    return Container(
      color: tileColor ?? AppColors.background,
      padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.gutter),
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
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.sectionHeader.copyWith(fontSize: 18.sp),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tileColor ?? AppColors.surfaceTonal,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.labelMicro.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.screenTitle.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
