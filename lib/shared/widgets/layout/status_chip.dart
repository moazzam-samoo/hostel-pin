import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

enum StatusChipType { available, active, traffic, pending, unavailable }

class StatusChip extends StatelessWidget {
  final StatusChipType type;

  const StatusChip({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (type) {
      case StatusChipType.available:
        bgColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        text = 'Available';
        break;
      case StatusChipType.active:
        // Matches the mockup: "Active" uses the same success green as
        // "Available", not an invented blue.
        bgColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        text = 'Active';
        break;
      case StatusChipType.traffic:
        bgColor = AppColors.secondary.withValues(alpha: 0.12);
        textColor = AppColors.secondary;
        text = 'Traffic';
        break;
      case StatusChipType.pending:
        bgColor = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
        text = 'Pending';
        break;
      case StatusChipType.unavailable:
        bgColor = AppColors.destructive.withValues(alpha: 0.12);
        textColor = AppColors.destructive;
        text = 'Full';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMicro.copyWith(
          color: textColor,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
