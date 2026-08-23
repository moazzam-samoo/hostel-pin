import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

enum LocationSource { currentLocation, chooseOnMap }

/// Bottom sheet offering the two ways an owner can set a hostel's location.
/// Resolves with the chosen [LocationSource], or `null` if dismissed.
Future<LocationSource?> showLocationSourceSheet() {
  return Get.bottomSheet<LocationSource>(
    const _LocationSourceSheetContent(),
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _LocationSourceSheetContent extends StatelessWidget {
  const _LocationSourceSheetContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.locationSourceSheetTitle,
                style: AppTextStyles.sectionHeader),
            SizedBox(height: AppSpacing.md),
            _SourceOption(
              icon: Icons.my_location,
              title: AppStrings.useCurrentLocationOption,
              subtitle: AppStrings.useCurrentLocationSubtitle,
              onTap: () => Get.back(result: LocationSource.currentLocation),
            ),
            _SourceOption(
              icon: Icons.map_outlined,
              title: AppStrings.chooseOnMapOption,
              subtitle: AppStrings.chooseOnMapSubtitle,
              onTap: () => Get.back(result: LocationSource.chooseOnMap),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.field),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  Text(subtitle,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
