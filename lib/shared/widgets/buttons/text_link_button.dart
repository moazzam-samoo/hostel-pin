import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TextLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isUnderlined;

  const TextLinkButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isUnderlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: isSecondary ? AppColors.secondary : AppColors.primary,
            decoration: isUnderlined ? TextDecoration.underline : null,
            decorationColor: isSecondary ? AppColors.secondary : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
