import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

/// Compact Student | Owner segmented control for the Login screen. Pure
/// presentation: the selected role and the change callback come from the
/// caller (LoginController).
class AccountTypeSwitch extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  const AccountTypeSwitch({
    super.key,
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
        children: [
          _segment(AppStrings.studentSectionTitle, UserRole.student),
          _segment(AppStrings.ownerSectionTitle, UserRole.owner),
        ],
      ),
    );
  }

  Widget _segment(String label, UserRole role) {
    final isSelected = selected == role;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.field),
          onTap: () => onChanged(role),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: Text(
              label,
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
