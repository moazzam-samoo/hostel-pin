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
      // maxCrossAxisExtent: 280 keeps this a 2-up grid at the 375px design
      // baseline (and at 320px) while reflowing to 3-up at 768px+ tablet
      // widths, given this widget's own crossAxisSpacing (AppSpacing.sm,
      // itself .w-scaled) and the AppSpacing.gutter padding every call site
      // wraps it in (see AGENTS.md's grid-reflow note for the arithmetic).
      // childAspectRatio (not a fixed mainAxisExtent) is deliberate: because
      // AppSpacing.sm and FacilityTile's title/subtitle .sp both scale with
      // screen WIDTH, a tile's real content height grows substantially on
      // wide/tablet/landscape screens (measured ~106-112px at 768-812px
      // wide vs ~54px at the 375px baseline) — a fixed mainAxisExtent tall
      // enough for tablets would look oversized on phones, and one sized
      // for phones overflows on tablets (this was a real, reproducible
      // RenderFlex overflow found via Block D.5's automated screen-size
      // tests). 2.0 keeps a comfortable margin over measured content height
      // at every tested width (320–812px, portrait and landscape).
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.0,
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
