import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_sizes.dart';

enum SettingsRowTrailing { chevron, toggle, none }

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final SettingsRowTrailing trailing;
  final VoidCallback? onTap;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    this.trailing = SettingsRowTrailing.chevron,
    this.onTap,
    this.toggleValue = false,
    this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDestructive ? AppColors.destructive : AppColors.textPrimary;

    Widget? trailingWidget;
    switch (trailing) {
      case SettingsRowTrailing.chevron:
        trailingWidget = const Icon(Icons.arrow_forward,
            color: AppColors.textTertiary, size: 18);
        break;
      case SettingsRowTrailing.toggle:
        trailingWidget = Switch(
          value: toggleValue,
          onChanged: onToggleChanged,
          activeThumbColor: AppColors.background,
          activeTrackColor: AppColors.primary,
        );
        break;
      case SettingsRowTrailing.none:
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconTile,
              height: AppSizes.iconTile,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.destructive
                    : AppColors.primaryVariant,
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
              child: Icon(
                icon,
                color: AppColors.background,
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
                    style: AppTextStyles.body.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }
}
