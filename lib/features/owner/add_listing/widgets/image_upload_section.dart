import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_listing_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/media/network_image_box.dart';
import '../../../../shared/widgets/media/upload_placeholder.dart';

class ImageUploadSection extends GetView<AddListingController> {
  const ImageUploadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photos = controller.photos;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UploadPlaceholder(
            label: AppStrings.uploadPicturesLabel,
            onTap: controller.pickImages,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.photosSelectedCount(photos.length),
            style: AppTextStyles.caption.copyWith(
              color:
                  photos.length < 5 ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          if (photos.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: photos.map((url) => _buildPhotoThumb(url)).toList(),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildPhotoThumb(String url) {
    return Container(
      margin: EdgeInsets.only(right: AppSpacing.sm),
      width: 80,
      height: 80,
      child: Stack(
        children: [
          url.startsWith('http')
              ? NetworkImageBox(
                  imageUrl: url,
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.circular(AppRadius.field),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.field),
                  child: Image.file(
                    File(url),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                controller.photos.remove(url);
              },
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xxs),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
