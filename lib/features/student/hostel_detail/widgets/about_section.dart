import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class AboutSection extends StatelessWidget {
  final String description;

  const AboutSection({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: AppTextStyles.body,
    );
  }
}
