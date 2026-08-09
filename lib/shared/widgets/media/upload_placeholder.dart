import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class UploadPlaceholder extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const UploadPlaceholder({
    super.key,
    this.label = 'Tap to upload',
    required this.onTap,
    this.height = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceTonal,
          borderRadius: BorderRadius.circular(AppRadius.card),
          // We can use a dashed border package or CustomPaint for dashed border
          // For simplicity without external deps, we'll use a solid border here
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
