import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_text_styles.dart';

class LocationTag extends StatelessWidget {
  final String location;

  const LocationTag({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.mapPin,
          width: 14,
          height: 14,
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style: AppTextStyles.locationTag,
        ),
      ],
    );
  }
}
