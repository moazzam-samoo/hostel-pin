import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'network_image_box.dart';

class PhotoGrid extends StatelessWidget {
  final List<String> imageUrls;
  final VoidCallback? onSeeAll;

  const PhotoGrid({
    super.key,
    required this.imageUrls,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: NetworkImageBox(
              imageUrl: imageUrls[0],
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(AppRadius.card),
              ),
            ),
          ),
          if (imageUrls.length > 1) ...[
            SizedBox(width: AppSpacing.xs),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: NetworkImageBox(
                      imageUrl: imageUrls[1],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(AppRadius.card),
                        bottomRight: Radius.circular(
                            imageUrls.length == 2 ? AppRadius.card : 0),
                      ),
                    ),
                  ),
                  if (imageUrls.length > 2) ...[
                    SizedBox(height: AppSpacing.xs),
                    Expanded(
                      child: GestureDetector(
                        onTap: onSeeAll,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkImageBox(
                              imageUrl: imageUrls[2],
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(AppRadius.card),
                              ),
                            ),
                            if (imageUrls.length > 3)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.only(
                                    bottomRight:
                                        Radius.circular(AppRadius.card),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+${imageUrls.length - 3}',
                                  style: AppTextStyles.sectionHeader
                                      .copyWith(color: AppColors.background),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
