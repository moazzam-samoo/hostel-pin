import 'package:flutter/material.dart';
import '../../../../shared/widgets/media/map_panel.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/directions_launcher.dart';

class DetailLocationSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String hostelName;

  const DetailLocationSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.hostelName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MapPanel(
          mode: MapPanelMode.readonly,
          latitude: latitude,
          longitude: longitude,
          markerLabel: hostelName,
        ),
        SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          text: AppStrings.getDirectionsButton,
          icon: const Icon(Icons.directions,
              size: 20, color: AppColors.background),
          expand: true,
          onPressed: () => openDirectionsTo(
            latitude: latitude,
            longitude: longitude,
            title: hostelName,
          ),
        ),
      ],
    );
  }
}
