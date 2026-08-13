import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'saved_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/feedback/empty_state.dart';
import '../../../shared/widgets/cards/hostel_card.dart';
import '../../../shared/widgets/layout/section_header.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../shell/student_shell_controller.dart';

import '../../../core/routes/app_routes.dart';

class SavedView extends GetView<SavedController> {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.brand,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (controller.savedHostels.isEmpty) {
                return Column(
                  children: [
                    SizedBox(height: AppSpacing.xl),
                    const EmptyState(
                      icon: Icons.favorite_border,
                      title: AppStrings.savedEmptyTitle,
                      message: AppStrings.savedEmptyMessage,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      text: AppStrings.startBrowsing,
                      expand: true,
                      onPressed: () => Get.find<StudentShellController>().onTabSelected(0),
                    ),
                    SizedBox(height: AppSpacing.xl),
                  ],
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.savedHostels.length,
                separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final hostel = controller.savedHostels[index];
                  return HostelCard(
                    id: hostel.id,
                    name: hostel.name,
                    location: hostel.city,
                    price: hostel.pricePerMonth,
                    rating: hostel.rating,
                    imageUrl: hostel.photos.first,
                    layout: HostelCardLayout.saved,
                    surface: HostelCardSurface.outlined,
                    isSaved: true,
                    onHeartTap: () => controller.removeSaved(hostel.id),
                    onTap: () => Get.toNamed(Routes.studentHostelDetail, arguments: hostel),
                  );
                },
              );
            }),
            SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: AppStrings.youMightAlsoLike),
            SizedBox(height: AppSpacing.md),
            Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.suggestedHostels.length,
              separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final hostel = controller.suggestedHostels[index];
                return HostelCard(
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
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
