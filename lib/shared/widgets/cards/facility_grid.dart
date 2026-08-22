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
      // maxCrossAxisExtent: 280 keeps this a 2-up grid at the 375px design
      // baseline (and at 320px) while reflowing to 3-up at 768px+ tablet
      // widths, given this widget's own unscaled 12px spacing and the
      // AppSpacing.gutter padding every call site wraps it in (see
      // AGENTS.md's grid-reflow note for the arithmetic).
      // childAspectRatio (not a fixed mainAxisExtent) is deliberate: because
      // FacilityTile's title/subtitle .sp scales with screen WIDTH, a
      // tile's real content height grows substantially on wide/tablet/
      // landscape screens (measured ~106-112px at 768-812px wide vs ~54px
      // at the 375px baseline) — a fixed mainAxisExtent tall enough for
      // tablets would look oversized on phones, and one sized for phones
      // overflows on tablets (this was a real, reproducible RenderFlex
      // overflow found via Block D.5's automated screen-size tests). 2.0
      // keeps a comfortable margin over measured content height at every
      // tested width (320–812px, portrait and landscape).
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.0,
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
