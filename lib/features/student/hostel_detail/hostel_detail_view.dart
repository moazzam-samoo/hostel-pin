import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hostel_detail_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/availability_status.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/buttons/icon_square_button.dart';
import '../../../shared/widgets/media/photo_grid.dart';
import '../../../shared/widgets/layout/status_chip.dart';
import '../../../shared/widgets/layout/price_label.dart';
import '../../../shared/widgets/layout/section_header.dart';
import 'widgets/contact_action_row.dart';
import '../../../shared/widgets/cards/facility_grid.dart';
import 'widgets/about_section.dart';
import 'widgets/detail_location_section.dart';
import 'widgets/photo_viewer_view.dart';
import '../../../shared/widgets/buttons/text_link_button.dart';

class HostelDetailView extends GetView<HostelDetailController> {
  const HostelDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Opened without a HostelModel argument (deep link / restored route):
    // the controller already pops the route; render nothing meanwhile instead
    // of reading an uninitialised `late` field.
    if (!controller.hasHostel) return const Scaffold(body: SizedBox.shrink());
    final hostel = controller.hostel;

    return Scaffold(
      appBar: AppTopBar(
        variant: AppTopBarVariant.brandWithBack,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Obx(
                () => Tooltip(
                  message: controller.isSaved.value ? 'Remove from Saved' : 'Save Hostel',
                  child: IconSquareButton(
                    icon: controller.isSaved.value
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    iconColor: controller.isSaved.value
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    borderColor: controller.isSaved.value
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.border,
                    onPressed: controller.toggleSaved,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoGrid(
              imageUrls: hostel.photos.map((p) => p.url).toList(),
              onSeeAll: () {
                Get.to(() => PhotoViewerView(imageUrls: hostel.photos.map((p) => p.url).toList()));
              },
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hostel.name,
                          style: AppTextStyles.screenTitle,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      StatusChip(
                        type:
                            hostel.availability == AvailabilityStatus.available
                                ? StatusChipType.available
                                : StatusChipType.unavailable,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '${AppStrings.locationPrefix}${hostel.fullAddress}',
                    style: AppTextStyles.body,
                  ),
                  SizedBox(height: AppSpacing.md),
                  PriceLabel(price: hostel.pricePerMonth),
                  SizedBox(height: AppSpacing.xl),
                  ContactActionRow(
                    phone: hostel.contactPhone,
                    whatsapp: hostel.contactWhatsapp,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: AppStrings.premiumFacilities),
                  SizedBox(height: AppSpacing.md),
                  FacilityGrid(amenities: hostel.amenities),
                  SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: AppStrings.aboutHostel),
                  SizedBox(height: AppSpacing.md),
                  AboutSection(description: hostel.description),
                  SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: AppStrings.hostelLocationHeader),
                  SizedBox(height: AppSpacing.md),
                  DetailLocationSection(
                    latitude: hostel.latitude,
                    longitude: hostel.longitude,
                    hostelName: hostel.name,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextLinkButton(
                      text: AppStrings.reportListing,
                      onPressed: controller.showReportSheet,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
