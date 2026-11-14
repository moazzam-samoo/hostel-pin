import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class SegmentOption<T> {
  final T value;
  final String label;
  const SegmentOption({required this.value, required this.label});
}

/// Compact segmented control (2 or more options). Pure presentation: the
/// selected value and the change callback come from the caller. Used for the
/// Login Student | Owner switch and the owner's Boys | Girls hostel type.
class SegmentedToggle<T> extends StatelessWidget {
  final List<SegmentOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;

  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.segment,
      decoration: BoxDecoration(
        color: AppColors.surfaceTonal,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [for (final option in options) _segment(option)],
      ),
    );
  }

  Widget _segment(SegmentOption<T> option) {
    final isSelected = selected == option.value;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: option.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.field),
          onTap: () => onChanged(option.value),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: Text(
              option.label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.background : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
