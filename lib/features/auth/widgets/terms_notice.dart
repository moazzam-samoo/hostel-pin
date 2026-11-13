import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// "By logging in, you agree to our Terms of Service and Privacy Policy."
/// A compact, centered consent line with the two documents as tappable links.
/// Pure presentation: the caller decides what tapping a link does.
class TermsNotice extends StatelessWidget {
  final String prefix;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const TermsNotice({
    super.key,
    required this.prefix,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.caption.copyWith(color: AppColors.textSecondary);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prefix, style: base),
        _link(AppStrings.termsTitle, onTermsTap, base),
        Text(AppStrings.termsAgreeAnd, style: base),
        _link(AppStrings.privacyPolicyTitle, onPrivacyTap, base),
        Text('.', style: base),
      ],
    );
  }

  Widget _link(String label, VoidCallback onTap, TextStyle base) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: base.copyWith(
          color: AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
