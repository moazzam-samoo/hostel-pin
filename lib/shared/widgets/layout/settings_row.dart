import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

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
    final color = isDestructive ? AppColors.destructive : AppColors.textPrimary;

    Widget? trailingWidget;
    switch (trailing) {
      case SettingsRowTrailing.chevron:
        trailingWidget = const Icon(Icons.chevron_right, color: AppColors.textTertiary);
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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.gutter),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption,
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
