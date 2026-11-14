import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/hostel_gender.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// All | Boys | Girls filter chips (null = All). Selected chip is a solid
/// purple pill; the others are white. Scrolls horizontally if it ever needs
/// more room than the screen has (small phones, large text).
class CategoryChipRow extends StatelessWidget {
  final HostelGender? selected;
  final ValueChanged<HostelGender?> onChanged;

  const CategoryChipRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(AppStrings.categoryAll, selected == null, () => onChanged(null)),
          SizedBox(width: AppSpacing.md),
          for (final gender in HostelGender.values) ...[
            _chip(gender.label, selected == gender, () => onChanged(gender)),
            SizedBox(width: AppSpacing.md),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.field),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm2 + AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? AppColors.surface : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
