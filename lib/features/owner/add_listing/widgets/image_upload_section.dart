import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/upload_result_model.dart';
import '../add_listing_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/media/network_image_box.dart';
import '../../../../shared/widgets/media/upload_placeholder.dart';

class ImageUploadSection extends GetView<AddListingController> {
  // Must match whatever tag AddListingView (the parent) was given — see its
  // own doc comment for why the Add-tab and Edit-screen controllers are
  // tagged separately.
  //
  // GetX's own documented tag pattern, see AddListingView's identical
  // comment. NOTE: `super.tag` does NOT work here — GetView's constructor
  // (installed version 4.7.3) only accepts `key`, not `tag`; that
  // shorthand is a real compile error.
  @override
  // ignore: overridden_fields
  final String? tag;

  const ImageUploadSection({super.key, this.tag});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photos = controller.photos;

      if (photos.isEmpty) {
        return UploadPlaceholder(
          label: AppStrings.uploadPicturesLabel,
          onTap: controller.pickImages,
          height: 120,
        );
      }

      final isMinMet = photos.length >= 3;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.photosSelectedCount(photos.length),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isMinMet ? AppColors.textPrimary : AppColors.error,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isMinMet
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  isMinMet ? 'Min requirement met' : 'Min 3 required',
                  style: AppTextStyles.caption.copyWith(
                    color: isMinMet ? AppColors.primary : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ...photos.map((photo) => _buildPhotoThumb(photo)),
              if (photos.length < 10) _buildAddMoreButton(),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: controller.pickImages,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceTonal,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 26,
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add More',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumb(UploadResultModel photo) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.field),
              child: photo.publicId.isNotEmpty || photo.url.startsWith('http')
                  ? NetworkImageBox(
                      imageUrl: photo.url,
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(AppRadius.field),
                    )
                  : (photo.url.isNotEmpty && File(photo.url).existsSync()
                      ? Image.file(
                          File(photo.url),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.surfaceTonal,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image,
                              color: AppColors.textTertiary, size: 24),
                        )),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                controller.photos.remove(photo);
              },
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xxs),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
