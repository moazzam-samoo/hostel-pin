import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? leadingIcon;
  final bool obscureText;
  final Widget? trailing;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.leadingIcon,
    this.obscureText = false,
    this.trailing,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppSizes.field,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: enabled,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTextStyles.body.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              prefixIcon: leadingIcon != null
                  ? Icon(leadingIcon, color: AppColors.textSecondary, size: 20)
                  : null,
              suffixIcon: trailing,
              errorText:
                  null, // Displayed manually below for better height control
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
