import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../buttons/text_link_button.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  /// Optional call to action shown under the message.
  final String? actionLabel;
  final VoidCallback? onAction;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.error, size: 24),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyles.cardTitle.copyWith(color: AppColors.error),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (actionLabel != null && onAction != null)
                  TextLinkButton(text: actionLabel!, onPressed: onAction!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
