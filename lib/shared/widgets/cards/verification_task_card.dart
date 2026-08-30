import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum VerificationTaskStatus { notCompleted, pending, completed }

class VerificationTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VerificationTaskStatus status;
  final VoidCallback? onTap;

  const VerificationTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = status == VerificationTaskStatus.notCompleted && onTap == null;
    
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconBox(),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildStatusBadge(),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(
                isLocked ? Icons.lock_outline : Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: const BoxDecoration(
        color: AppColors.surfaceTonal,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.textPrimary,
        size: 24.sp,
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case VerificationTaskStatus.completed:
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.primary;
        text = 'Completed';
        break;
      case VerificationTaskStatus.pending:
        bgColor = AppColors.border; // grey
        textColor = AppColors.textPrimary;
        text = 'Pending';
        break;
      case VerificationTaskStatus.notCompleted:
        bgColor = AppColors.surfaceTonal;
        textColor = AppColors.textSecondary;
        text = 'Not Completed';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMicro.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
