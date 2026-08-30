import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class InstructionBox extends StatelessWidget {
  final String title;
  final List<String> instructions;

  const InstructionBox({
    super.key,
    this.title = 'Instructions',
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceTonal,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMicro.copyWith(
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ...instructions.map((text) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.secondary,
                      size: 18.sp,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        text,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class InfoInstructionBox extends StatelessWidget {
  final String text;

  const InfoInstructionBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceTonal,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info,
            color: AppColors.primary,
            size: 20.sp,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBox extends StatelessWidget {
  final String text;
  final bool isError;
  final bool isSuccess;

  const StatusBox({
    super.key,
    required this.text,
    this.isError = false,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.surfaceTonal;
    Color textColor = AppColors.textPrimary;
    Color iconColor = AppColors.textSecondary;
    IconData icon = Icons.info_outline;

    if (isError) {
      bgColor = AppColors.errorContainer.withValues(alpha: 0.3);
      textColor = AppColors.error;
      iconColor = AppColors.error;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      iconColor = AppColors.success;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24.sp,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: textColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
