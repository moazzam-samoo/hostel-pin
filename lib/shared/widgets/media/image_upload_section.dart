import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/models/upload_result_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'network_image_box.dart';
import 'upload_placeholder.dart';

class ImageUploadSection extends StatelessWidget {
  final List<UploadResultModel> photos;
  final VoidCallback onPickImages;
  final void Function(UploadResultModel) onRemovePhoto;
  final int minRequired;
  final int maxPhotos;
  final String placeholderLabel;

  const ImageUploadSection({
    super.key,
    required this.photos,
    required this.onPickImages,
    required this.onRemovePhoto,
    this.minRequired = 3,
    this.maxPhotos = 10,
    this.placeholderLabel = AppStrings.uploadPicturesLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return UploadPlaceholder(
        label: placeholderLabel,
        onTap: onPickImages,
        height: 120,
      );
    }

    final isMinMet = photos.length >= minRequired;

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
                isMinMet ? 'Min requirement met' : 'Min $minRequired required',
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
            if (photos.length < maxPhotos) _buildAddMoreButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: onPickImages,
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
              onTap: () => onRemovePhoto(photo),
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
