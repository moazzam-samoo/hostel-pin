import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class ScreenTitleBlock extends StatelessWidget {
  final String title;
  final String? subtitle;

  const ScreenTitleBlock({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.screenTitle,
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTextStyles.screenSubtitle,
          ),
        ],
      ],
    );
  }
}
