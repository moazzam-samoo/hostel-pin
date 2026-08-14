import 'package:flutter/material.dart';
import '../../../core/enums/amenity.dart';
import 'facility_tile.dart';

class FacilityGrid extends StatelessWidget {
  final Set<Amenity> amenities;

  const FacilityGrid({
    super.key,
    required this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities.elementAt(index);
        return FacilityTile(
          icon: amenity.icon,
          title: amenity.title,
          subtitle: amenity.subtitle,
          style: FacilityTileStyle.read,
        );
      },
    );
  }
}
