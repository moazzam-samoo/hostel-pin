import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../media/network_image_box.dart';

class ActivityRow extends StatelessWidget {
  final String title;
  final String timeAgo;
  final IconData icon;
  final String? imageUrl;
  final String? message;

  const ActivityRow({
    super.key,
    required this.title,
    required this.timeAgo,
    required this.icon,
    this.imageUrl,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTonal,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body,
                ),
                if (message != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                SizedBox(height: AppSpacing.xs),
                Text(
                  timeAgo,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          if (imageUrl != null) ...[
            SizedBox(width: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: NetworkImageBox(
                imageUrl: imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
