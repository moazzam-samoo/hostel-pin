import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/widgets/inputs/segmented_toggle.dart';

/// Student | Owner switch for the Login screen: a thin wrapper over the shared
/// [SegmentedToggle]. The caller (LoginController) owns the selected role.
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
    return SegmentedToggle<UserRole>(
      selected: selected,
      onChanged: onChanged,
      options: const [
        SegmentOption(value: UserRole.student, label: AppStrings.studentSectionTitle),
        SegmentOption(value: UserRole.owner, label: AppStrings.ownerSectionTitle),
      ],
    );
  }
}
