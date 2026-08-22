import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum FieldLabelStyle { form, auth }

class FieldLabel extends StatelessWidget {
  final String text;
  final FieldLabelStyle style;
  final bool isRequired;

  const FieldLabel(
    this.text, {
    super.key,
    this.style = FieldLabelStyle.form,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style == FieldLabelStyle.form
        ? AppTextStyles.labelMicro
        : AppTextStyles.labelSentence;

    final displayText =
        style == FieldLabelStyle.form ? text.toUpperCase() : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: RichText(
        text: TextSpan(
          text: displayText,
          style: baseStyle,
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: baseStyle.copyWith(color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}
