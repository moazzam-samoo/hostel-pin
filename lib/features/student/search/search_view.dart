import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'search_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../shared/widgets/buttons/icon_square_button.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/layout/section_header.dart';
import '../../../shared/widgets/cards/hostel_card.dart';
import '../../../shared/widgets/layout/settings_row.dart';
import '../../../shared/widgets/layout/auth_hero_sheet.dart';
import '../../../shared/widgets/inputs/amenity_selector.dart';
import '../../../shared/widgets/layout/form_section_header.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  void _showFilterSheet() {
    // Local state for the sheet to apply on save
    bool sortByPrice = controller.isSortPriceLowToHigh.value;
    bool sortByRating = controller.isSortRatingHighToLow.value;
    RangeValues price = controller.priceRange.value;
    final amenities = {...controller.selectedAmenities};

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
        return AuthHeroSheet(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: AppStrings.filterTitle),
                SizedBox(height: AppSpacing.md),

                FormSectionHeader(
                  title: AppStrings.priceRangeLabel,
                  description: 'Rs ${price.start.round()} — Rs ${price.end.round()}',
                ),
                RangeSlider(
                  values: price,
                  min: SearchController.minPrice,
                  max: SearchController.maxPrice,
                  divisions: 30,
                  activeColor: AppColors.primary,
                  labels: RangeLabels(
                    'Rs ${price.start.round()}',
                    'Rs ${price.end.round()}',
                  ),
                  onChanged: (v) => setState(() => price = v),
                ),
                SizedBox(height: AppSpacing.md),

                const FormSectionHeader(title: AppStrings.amenitiesLabel),
                AmenitySelector(
                  selectedAmenities: amenities,
                  onToggle: (amenity) => setState(() {
                    if (amenities.contains(amenity)) {
                      amenities.remove(amenity);
                    } else {
                      amenities.add(amenity);
                    }
                  }),
                ),
                SizedBox(height: AppSpacing.md),

                SettingsRow(
                  icon: Icons.attach_money,
                  title: AppStrings.sortPriceLowHigh,
                  trailing: SettingsRowTrailing.toggle,
                  toggleValue: sortByPrice,
                  onToggleChanged: (v) {
                    setState(() {
                      sortByPrice = v;
                      if (v) sortByRating = false;
                    });
                  },
                ),
                SettingsRow(
                  icon: Icons.star,
                  title: AppStrings.sortRating,
                  trailing: SettingsRowTrailing.toggle,
                  toggleValue: sortByRating,
                  onToggleChanged: (v) {
                    setState(() {
                      sortByRating = v;
                      if (v) sortByPrice = false;
                    });
                  },
                ),
                SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: AppStrings.resetFilters,
                        onPressed: () {
                          controller.resetFilters();
                          Get.back();
                        },
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        text: AppStrings.applyFilters,
                        onPressed: () {
                          controller.selectedAmenities
                            ..clear()
                            ..addAll(amenities);
                          controller.applyFilters(
                            sortByPrice: sortByPrice,
                            sortByRating: sortByRating,
                            price: price,
                          );
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.backOnly,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    hintText: AppStrings.searchHint,
                    controller: controller.searchController,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                IconSquareButton(
                  icon: Icons.tune,
                  onPressed: _showFilterSheet,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Expanded(
            child: Obx(() {
              if (controller.searchQuery.value.trim().isEmpty) {
                return _buildRecentSearches();
              } else if (controller.searchResults.isEmpty) {
                return _buildEmptyState();
              } else {
                return _buildResultsList();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      children: [
        const SectionHeader(title: AppStrings.recentSearches),
        SizedBox(height: AppSpacing.sm),
        ...controller.recentSearches.map((search) => ListTile(
          leading: const Icon(Icons.history, color: AppColors.textSecondary),
          title: Text(search, style: AppTextStyles.body),
          contentPadding: EdgeInsets.zero,
          onTap: () {
            controller.searchController.text = search;
          },
        )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.textTertiary),
          SizedBox(height: AppSpacing.md),
          Text(
            AppStrings.noResultsTitle,
            style: AppTextStyles.sectionHeader,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.noResultsMessage,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.gutter),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final hostel = controller.searchResults[index];
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
    );
  }
}
