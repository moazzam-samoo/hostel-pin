import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HighlightedBodyText extends StatelessWidget {
  final String textBefore;
  final String highlightedText;
  final String textAfter;

  const HighlightedBodyText({
    super.key,
    required this.textBefore,
    required this.highlightedText,
    required this.textAfter,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        children: [
          TextSpan(text: textBefore),
          TextSpan(
            text: highlightedText,
            style: AppTextStyles.body.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: textAfter),
        ],
      ),
    );
  }
}
