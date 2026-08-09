import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_sizes.dart';

enum ButtonIntent { primary, secondary, neutral }

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final double? width;
  final bool expand;
  final ButtonIntent intent;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.expand = false,
    this.intent = ButtonIntent.neutral,
  });

  Color get _contentColor {
    switch (intent) {
      case ButtonIntent.primary:
        return AppColors.primary;
      case ButtonIntent.secondary:
        return AppColors.secondary;
      case ButtonIntent.neutral:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _contentColor;
    
    return SizedBox(
      width: expand ? double.infinity : width,
      height: AppSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading || isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: isDisabled ? AppColors.placeholder : color,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(color: color),
                  ),
                ],
              ),
      ),
    );
  }
}
