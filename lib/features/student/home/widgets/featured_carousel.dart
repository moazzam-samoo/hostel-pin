import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../home_controller.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../shared/widgets/cards/hostel_card.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class FeaturedCarousel extends GetView<HomeController> {
  final List<HostelModel> hostels;

  const FeaturedCarousel({super.key, required this.hostels});

  /// Share of the screen width one featured card takes (the next one peeks).
  static const double _viewportFraction = 0.70;

  /// Horizontal gap the carousel puts around each card (8 + 8).
  static const double _cardGutter = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The featured card is a square image plus a text block, so its height
        // follows its WIDTH. Derive the carousel height from the screen width
        // (and text scale) instead of a fixed number that would overflow on
        // wider phones or with large text.
        final cardWidth = constraints.maxWidth * _viewportFraction - _cardGutter;
        final scaler = MediaQuery.textScalerOf(context);
        // Text heights come from the real (already screen-scaled) text
        // styles, so the estimate also holds on tablets and large text.
        final titleHeight =
            scaler.scale(AppTextStyles.cardTitle.fontSize ?? 16) * 1.7;
        final captionHeight =
            scaler.scale(AppTextStyles.caption.fontSize ?? 12) * 1.7;
        final height = cardWidth +
            AppSpacing.md * 2 +
            AppSpacing.xs +
            (titleHeight > 32 ? titleHeight : 32) + // heart button is 28 tall
            captionHeight +
            12; // slack

        return CarouselSlider.builder(
          itemCount: hostels.length,
          itemBuilder: (context, index, realIndex) {
            final hostel = hostels[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: _cardGutter / 2),
              child: Obx(() => HostelCard(
                    id: hostel.id,
                    name: hostel.name,
                    location: hostel.city,
                    price: hostel.pricePerMonth,
                    rating: hostel.rating,
                    imageUrl: hostel.photos.isNotEmpty
                        ? hostel.photos.first.url
                        : '',
                    ownerName: hostel.ownerName,
                    amenities: hostel.amenities,
                    layout: HostelCardLayout.featured,
                    surface: HostelCardSurface.elevated,
                    isSaved: controller.isSaved(hostel.id),
                    onHeartTap: () => controller.toggleSaved(hostel.id),
                    onTap: () => Get.toNamed(Routes.studentHostelDetail,
                        arguments: hostel),
                  )),
            );
          },
          options: CarouselOptions(
            height: height,
            viewportFraction: _viewportFraction,
            enableInfiniteScroll: false,
            padEnds: false,
          ),
        );
      },
    );
  }
}
