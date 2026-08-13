import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/buttons/icon_circle_button.dart';
import '../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../shared/widgets/layout/section_header.dart';
import '../../../shared/widgets/feedback/state_view.dart';
import '../../../shared/widgets/cards/hostel_card.dart';
import 'widgets/featured_carousel.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        variant: AppTopBarVariant.brand,
        actions: [
          IconCircleButton(
            icon: Icons.more_vert,
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() => StateView(
        state: controller.status.value,
        contentBuilder: _buildContent(context),
      )),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.gutter),
            child: AppSearchBar(
              hintText: AppStrings.searchHint,
              readOnly: true,
              onTap: () => Get.toNamed(Routes.studentSearch),
            ),
          ),
          if (controller.featuredHostels.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: SectionHeader(
                title: AppStrings.featuredHostels,
                trailingText: AppStrings.viewAll,
                onTrailingTap: () {},
              ),
            ),
            SizedBox(height: AppSpacing.md),
            FeaturedCarousel(hostels: controller.featuredHostels),
            SizedBox(height: AppSpacing.xl),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: const SectionHeader(
              title: AppStrings.allHostelsSection,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppSpacing.gutter),
            itemCount: controller.regularHostels.length,
            separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final hostel = controller.regularHostels[index];
              return Obx(() => HostelCard(
                id: hostel.id,
                name: hostel.name,
                location: hostel.city,
                price: hostel.pricePerMonth,
                rating: hostel.rating,
                imageUrl: hostel.photos.first,
                layout: HostelCardLayout.compact,
                surface: HostelCardSurface.tonal,
                isSaved: controller.isSaved(hostel.id),
                onHeartTap: () => controller.toggleSaved(hostel.id),
                onTap: () => Get.toNamed(Routes.studentHostelDetail, arguments: hostel),
              ));
            },
          ),
        ],
      ),
    );
  }
}
