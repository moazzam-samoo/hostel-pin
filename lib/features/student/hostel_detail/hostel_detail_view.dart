import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'hostel_detail_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/availability_status.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/media/photo_grid.dart';
import '../../../shared/widgets/layout/status_chip.dart';
import '../../../shared/widgets/layout/price_label.dart';
import '../../../shared/widgets/layout/section_header.dart';
import 'widgets/contact_action_row.dart';
import '../../../shared/widgets/cards/facility_grid.dart';
import 'widgets/about_section.dart';
import 'widgets/detail_location_section.dart';
import 'widgets/photo_viewer_view.dart';

class HostelDetailView extends GetView<HostelDetailController> {
  const HostelDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final hostel = controller.hostel;

    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.brandWithBack,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoGrid(
              imageUrls: hostel.photos,
              onSeeAll: () {
                Get.to(() => PhotoViewerView(imageUrls: hostel.photos));
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
                        type: hostel.availability == AvailabilityStatus.available
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
