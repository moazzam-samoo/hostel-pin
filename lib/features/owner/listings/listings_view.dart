import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'listings_controller.dart';
import 'widgets/owner_listing_card.dart';
import '../../../data/models/hostel_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/layout/screen_title_block.dart';
import '../../../shared/widgets/feedback/empty_state.dart';
import '../../../shared/widgets/cards/facility_grid.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/buttons/icon_square_button.dart';

class ListingsView extends GetView<ListingsController> {
  const ListingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(variant: AppTopBarVariant.brand),
      body: Obx(() {
        final listings = controller.ownerListings;

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
                child: const ScreenTitleBlock(
                  title: AppStrings.myHostels,
                  subtitle: AppStrings.myHostelsSubtitle,
                ),
              ),
              if (listings.isEmpty)
                _buildEmptyState()
              else
                ...listings.map((hostel) => _buildListingItem(hostel)),
              SizedBox(height: AppSpacing.xl),
              _buildPromoFooter(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.gutter),
      child: const EmptyState(
        title: AppStrings.noListingsTitle,
        message: AppStrings.noListingsMessage,
        icon: Icons.list_alt,
      ),
    );
  }

  Widget _buildListingItem(HostelModel hostel) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppSpacing.gutter,
          right: AppSpacing.gutter,
          bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OwnerListingCard(hostel: hostel),
          SizedBox(height: AppSpacing.md),
          FacilityGrid(amenities: hostel.amenities.take(4).toSet()),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: AppStrings.editButton,
                  intent: ButtonIntent.primary,
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                  onPressed: () => controller.editListing(hostel),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              IconSquareButton(
                icon: Icons.delete_outline,
                borderColor: AppColors.secondary,
                iconColor: AppColors.secondary,
                size: 44,
                onPressed: () => controller.deleteListing(hostel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, color: AppColors.primary, size: 28),
              SizedBox(width: AppSpacing.sm),
              // Flexible (letting the heading wrap instead of forcing one
              // line) avoids a RenderFlex overflow at narrow widths/large
              // text scale — found via Phase 5's D.5 pass (TASK-Phase-5.md).
              Flexible(
                child: Text(
                  AppStrings.expandReachTitle,
                  style: AppTextStyles.sectionHeader
                      .copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.expandReachSubtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: controller.navigateToAddListing,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.sm, horizontal: AppSpacing.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flexible + ellipsis guards against RenderFlex overflow at
                // large text scale (1.3x) — found via Phase 5's D.5 pass
                // (TASK-Phase-5.md).
                Flexible(
                  child: Text(
                    AppStrings.addAnotherHostel,
                    style:
                        AppTextStyles.button.copyWith(color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                const Icon(Icons.arrow_forward,
                    color: AppColors.primary, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
