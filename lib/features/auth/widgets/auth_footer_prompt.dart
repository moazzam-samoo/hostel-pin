import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/buttons/text_link_button.dart';

class AuthFooterPrompt extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onPressed;

  const AuthFooterPrompt({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        TextLinkButton(
          text: actionText,
          onPressed: onPressed,
          isSecondary: true,
        ),
      ],
    );
  }
}
