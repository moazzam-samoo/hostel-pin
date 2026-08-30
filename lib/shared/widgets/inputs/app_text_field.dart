import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // maxLines/minLines default to single-line (1), matching every pre-existing
  // call site's behavior exactly. Only when maxLines > 1 does the field grow
  // with content instead of using AppSizes.field's fixed single-line height.
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

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
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? 1 : minLines,
      style: AppTextStyles.body.copyWith(
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        prefixIcon: leadingIcon != null
            ? Icon(leadingIcon, color: AppColors.textSecondary, size: 20)
            : null,
        suffixIcon: trailing,
        errorText: null, // Displayed manually below for better height control
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        maxLines == 1 ? SizedBox(height: AppSizes.field, child: field) : field,
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
