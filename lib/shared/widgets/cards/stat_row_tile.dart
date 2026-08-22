import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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

  Widget _buildCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: tileColor ?? AppColors.surfaceTonal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 28),
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
                style: AppTextStyles.labelMicro.copyWith(
                  color: iconColor ?? AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.screenTitle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
