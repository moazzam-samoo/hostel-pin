import 'package:flutter/material.dart';
import '../../../core/enums/amenity.dart';
import '../../../core/theme/app_spacing.dart';
import '../cards/facility_tile.dart';

class AmenitySelector extends StatelessWidget {
  final Set<Amenity> selectedAmenities;
  final ValueChanged<Amenity> onToggle;

  const AmenitySelector({
    super.key,
    required this.selectedAmenities,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.5,
      ),
      itemCount: Amenity.values.length,
      itemBuilder: (context, index) {
        final amenity = Amenity.values[index];
        final isSelected = selectedAmenities.contains(amenity);

        return FacilityTile(
          icon: amenity.icon,
          title: amenity.title,
          subtitle: amenity.subtitle,
          style: FacilityTileStyle.select,
          isSelected: isSelected,
          onTap: () => onToggle(amenity),
        );
      },
    );
  }
}
