import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class VerificationBreadcrumb extends StatelessWidget {
  final int currentStep; // 1 to 5
  final List<String> stepNames;
  final ScrollController _scrollController = ScrollController();

  VerificationBreadcrumb({
    super.key,
    required this.currentStep,
    this.stepNames = const [
      'Personal',
      'Identity',
      'Hostel',
      'Documents',
      'Review',
    ],
  });

  @override
  Widget build(BuildContext context) {
    // We want to auto-scroll to center the active step if possible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final position = (currentStep - 1) * 80.w; // Rough estimate of item width
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: stepNames.length,
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(
            Icons.arrow_forward,
            size: 14.sp,
            color: AppColors.textTertiary,
          ),
        ),
        itemBuilder: (context, index) {
          final stepNum = index + 1;
          final isCompleted = stepNum < currentStep;
          final isActive = stepNum == currentStep;
          final isUpcoming = stepNum > currentStep;

          return _buildStepItem(stepNum, stepNames[index], isActive, isCompleted, isUpcoming);
        },
      ),
    );
  }

  Widget _buildStepItem(int stepNum, String name, bool isActive, bool isCompleted, bool isUpcoming) {
    final bgColor = (isActive || isCompleted) ? AppColors.primary : Colors.transparent;
    final borderColor = (isActive || isCompleted) ? AppColors.primary : AppColors.textTertiary;
    final textColor = (isActive || isCompleted) ? Colors.white : AppColors.textTertiary;
    final labelColor = (isActive || isCompleted) ? AppColors.primary : AppColors.textTertiary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(
              '$stepNum',
              style: AppTextStyles.labelMicro.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          name,
          style: AppTextStyles.body.copyWith(
            color: labelColor,
            fontSize: 13.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
