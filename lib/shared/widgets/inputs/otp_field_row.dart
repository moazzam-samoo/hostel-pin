import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../buttons/text_link_button.dart';
import 'app_text_field.dart';

class OtpFieldRow extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback onResend;
  final bool isLoading;
  final String? errorText;
  final void Function(String)? onChanged;

  const OtpFieldRow({
    super.key,
    this.controller,
    required this.onResend,
    this.isLoading = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            controller: controller,
            hintText: 'Enter 4-digit OTP',
            keyboardType: TextInputType.number,
            errorText: errorText,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextLinkButton(
            text: AppStrings.resendCode,
            onPressed: onResend,
          ),
        ),
      ],
    );
  }
}
