import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class PriceLabel extends StatelessWidget {
  final num price;

  const PriceLabel({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          Formatters.currency(price),
          style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary),
        ),
        Text(
          ' /month',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
