import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bottom sheet offering camera vs. gallery for a document photo (CNIC,
/// ownership papers). Mirrors location_source_sheet.dart's pattern.
/// Resolves with the chosen [ImageSource], or `null` if dismissed.
///
/// Deliberately NOT used for the selfie capture (verification_controller.dart's
/// captureImage stays camera-only) — a liveness selfie must be a live
/// capture, but a CNIC/property-document photo is very often an existing
/// scan the owner already has, so forcing a fresh photo there was a real
/// usability gap, not a security requirement the way the selfie is.
Future<ImageSource?> showImageSourceSheet() {
  return Get.bottomSheet<ImageSource>(
    const _ImageSourceSheetContent(),
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _ImageSourceSheetContent extends StatelessWidget {
  const _ImageSourceSheetContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.imageSourceSheetTitle,
                style: AppTextStyles.sectionHeader),
            SizedBox(height: AppSpacing.md),
            _SourceOption(
              icon: Icons.camera_alt_outlined,
              title: AppStrings.takePhotoOption,
              subtitle: AppStrings.takePhotoSubtitle,
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            _SourceOption(
              icon: Icons.photo_library_outlined,
              title: AppStrings.chooseFromGalleryOption,
              subtitle: AppStrings.chooseFromGallerySubtitle,
              onTap: () => Get.back(result: ImageSource.gallery),
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
