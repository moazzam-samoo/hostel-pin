import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../home_controller.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../shared/widgets/cards/hostel_card.dart';
import '../../../../core/routes/app_routes.dart';

class FeaturedCarousel extends GetView<HomeController> {
  final List<HostelModel> hostels;

  const FeaturedCarousel({super.key, required this.hostels});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: hostels.length,
      itemBuilder: (context, index, realIndex) {
        final hostel = hostels[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Obx(() => HostelCard(
            id: hostel.id,
            name: hostel.name,
            location: hostel.city,
            price: hostel.pricePerMonth,
            rating: hostel.rating,
            imageUrl: hostel.photos.first,
            layout: HostelCardLayout.featured,
            surface: HostelCardSurface.elevated,
            isSaved: controller.isSaved(hostel.id),
            onHeartTap: () => controller.toggleSaved(hostel.id),
            onTap: () => Get.toNamed(Routes.studentHostelDetail, arguments: hostel),
          )),
        );
      },
      options: CarouselOptions(
        height: 280, // Approximate height for featured card
        viewportFraction: 0.85, // Closer to 0.72 might clip too much, let's try 0.85
        enableInfiniteScroll: false,
        padEnds: false, // align to the left
      ),
    );
  }
}
