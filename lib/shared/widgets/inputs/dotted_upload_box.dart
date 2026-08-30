import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class DottedUploadBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final File? uploadedFile; // Can show preview or green check if uploaded

  const DottedUploadBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.uploadedFile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: AppColors.textSecondary,
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          radius: Radius.circular(12.r),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: uploadedFile != null ? AppColors.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                uploadedFile != null ? Icons.check_circle : icon,
                color: uploadedFile != null ? AppColors.success : AppColors.textSecondary,
                size: 32.sp,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                uploadedFile != null ? 'Image Uploaded' : title,
                style: AppTextStyles.cardTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                uploadedFile != null ? 'Tap to change' : subtitle,
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
