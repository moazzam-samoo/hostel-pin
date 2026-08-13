import 'package:flutter/material.dart';
import '../../../../shared/widgets/media/map_panel.dart';

class DetailLocationSection extends StatelessWidget {
  final double latitude;
  final double longitude;

  const DetailLocationSection({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    // We are passing static generic coordinates or using the provided ones for a readonly map.
    // Assuming MapPanel accepts mode or it's static.
    return const MapPanel(
      mode: MapPanelMode.readonly,
      // If MapPanel accepts coordinates, pass them here.
    );
  }
}
