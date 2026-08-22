import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'search_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../shared/widgets/buttons/icon_square_button.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/layout/section_header.dart';
import '../../../shared/widgets/cards/hostel_card.dart';
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
        return Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: AppStrings.filterTitle),
                SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.priceRangeLabel,
                      style: AppTextStyles.formSectionTitle,
                    ),
                    Flexible(
                      child: Text(
                        '${Formatters.currency(price.start)} — ${Formatters.currency(price.end)}',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                RangeSlider(
                  values: price,
                  min: SearchController.minPrice,
                  max: SearchController.maxPrice,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primaryContainer,
                  labels: RangeLabels(
                    Formatters.currency(price.start),
                    Formatters.currency(price.end),
                  ),
                  onChanged: (v) => setState(() => price = v),
                ),
                SizedBox(height: AppSpacing.md),
                const FormSectionHeader(title: AppStrings.amenitiesLabel),
                SizedBox(height: AppSpacing.xs),
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
                const FormSectionHeader(title: 'Sort By'),
                SizedBox(height: AppSpacing.xs),
                _SortOptionTile(
                  icon: Icons.attach_money,
                  title: AppStrings.sortPriceLowHigh,
                  isSelected: sortByPrice,
                  onTap: () {
                    setState(() {
                      sortByPrice = !sortByPrice;
                      if (sortByPrice) sortByRating = false;
                    });
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                _SortOptionTile(
                  icon: Icons.star_border,
                  title: AppStrings.sortRating,
                  isSelected: sortByRating,
                  onTap: () {
                    setState(() {
                      sortByRating = !sortByRating;
                      if (sortByRating) sortByPrice = false;
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
        variant: AppTopBarVariant.brandWithBack,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.gutter),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: controller.searchController,
                    hintText: AppStrings.searchHint,
                    onChanged: (v) => controller.searchQuery.value = v,
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
          Expanded(
            child: Obx(() {
              if (controller.searchQuery.value.trim().isEmpty) {
                return _buildRecentSearches();
              }
              if (controller.searchResults.isEmpty) {
                return _buildEmptyState();
              }
              return _buildResultsList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.gutter),
      children: [
        const SectionHeader(title: AppStrings.recentSearches),
        SizedBox(height: AppSpacing.sm),
        ...controller.recentSearches.map((search) => ListTile(
              leading:
                  const Icon(Icons.history, color: AppColors.textSecondary),
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
          amenities: hostel.amenities,
          layout: HostelCardLayout.compact,
          surface: HostelCardSurface.tonal,
          isSaved: controller.isSaved(hostel.id),
          onHeartTap: () => controller.toggleSaved(hostel.id),
          onTap: () =>
              Get.toNamed(Routes.studentHostelDetail, arguments: hostel),
        );
      },
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceTonal,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.background : AppColors.primary,
                size: 18,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
