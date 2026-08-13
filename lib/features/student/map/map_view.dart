import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../shared/widgets/cards/hostel_card.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => GoogleMap(
            initialCameraPosition: controller.initialPosition,
            markers: controller.markers.toSet(),
            onMapCreated: controller.onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: (_) => controller.selectedHostel.value = null,
          )),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.gutter),
              child: AppSearchBar(
                hintText: AppStrings.searchHint,
                readOnly: true,
                onTap: () => Get.toNamed(Routes.studentSearch),
              ),
            ),
          ),

          Obx(() {
            final selected = controller.selectedHostel.value;
            if (selected == null) return const SizedBox.shrink();

            return Positioned(
              left: AppSpacing.gutter,
              right: AppSpacing.gutter,
              bottom: AppSpacing.gutter,
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.studentHostelDetail, arguments: selected),
                child: HostelCard(
                  id: selected.id,
                  name: selected.name,
                  location: selected.city,
                  price: selected.pricePerMonth,
                  rating: selected.rating,
                  imageUrl: selected.photos.first,
                  layout: HostelCardLayout.compact,
                  surface: HostelCardSurface.elevated,
                  isSaved: controller.isSaved(selected.id),
                  onHeartTap: () => controller.toggleSaved(selected.id),
                  onTap: () => Get.toNamed(Routes.studentHostelDetail, arguments: selected),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: Obx(() {
        final padding = controller.selectedHostel.value != null ? 140.0 : AppSpacing.gutter;
        return Padding(
          padding: EdgeInsets.only(bottom: padding),
          child: FloatingActionButton(
            onPressed: controller.getCurrentLocation,
            backgroundColor: AppColors.primaryContainer,
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        );
      }),
    );
  }
}
