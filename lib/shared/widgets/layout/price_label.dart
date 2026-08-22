import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class PriceLabel extends StatelessWidget {
  final num price;
  final TextStyle? priceStyle;
  final TextStyle? suffixStyle;
  final String suffix;

  const PriceLabel({
    super.key,
    required this.price,
    this.priceStyle,
    this.suffixStyle,
    this.suffix = ' /month',
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
          style: priceStyle ??
              AppTextStyles.sectionHeader.copyWith(color: AppColors.primary),
        ),
        Text(
          suffix,
          style: suffixStyle ?? AppTextStyles.caption,
        ),
      ],
    );
  }
}
