import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

// Note: This widget is undesigned (no mockup shows it).
// It is included in case there is a legal requirement for terms acceptance during signup.
class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  /// Open the in-app Terms of Service / Privacy Policy. Both documents must
  /// be reachable from the screen where the user agrees to them.
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(AppStrings.termsAgreePrefix, style: AppTextStyles.body),
              _link(AppStrings.termsTitle, onTermsTap),
              Text(AppStrings.termsAgreeAnd, style: AppTextStyles.body),
              _link(AppStrings.privacyPolicyTitle, onPrivacyTap),
              Text('.', style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _link(String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
