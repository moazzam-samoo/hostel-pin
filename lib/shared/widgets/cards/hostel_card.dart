import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../media/network_image_box.dart';

enum HostelCardSurface { tonal, lavender, outlined, elevated }
enum HostelCardLayout { compact, featured, saved }

class HostelCard extends StatelessWidget {
  final String id;
  final String name;
  final String location;
  final num price;
  final double rating;
  final String imageUrl;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onHeartTap;
  final HostelCardSurface surface;
  final HostelCardLayout layout;

  const HostelCard({
    super.key,
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.isSaved = false,
    this.onTap,
    this.onHeartTap,
    this.surface = HostelCardSurface.elevated,
    this.layout = HostelCardLayout.compact,
  });

  BoxDecoration get _decoration {
    Color bgColor;
    Border? border;
    List<BoxShadow>? shadows;

    switch (surface) {
      case HostelCardSurface.tonal:
        bgColor = AppColors.surfaceTonal;
        break;
      case HostelCardSurface.lavender:
        bgColor = AppColors.primaryContainer;
        break;
      case HostelCardSurface.outlined:
        bgColor = AppColors.background;
        border = Border.all(color: AppColors.border);
        break;
      case HostelCardSurface.elevated:
        bgColor = AppColors.background;
        shadows = AppShadows.card;
        break;
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: border,
      boxShadow: shadows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        decoration: _decoration,
        clipBehavior: Clip.antiAlias,
        child: _buildLayout(),
      ),
    );
  }

  Widget _buildLayout() {
    switch (layout) {
      case HostelCardLayout.featured:
        return _buildFeatured();
      case HostelCardLayout.compact:
      case HostelCardLayout.saved:
        return _buildCompact();
    }
  }

  Widget _buildFeatured() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImage(),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _buildHeart(),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildRating(),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                location,
                style: AppTextStyles.locationTag,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildPrice(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompact() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSizes.thumb,
            height: AppSizes.thumb,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: _buildImage(),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (layout == HostelCardLayout.saved)
                      _buildHeart()
                    else
                      _buildRating(),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  location,
                  style: AppTextStyles.locationTag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.sm),
                _buildPrice(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Outer containers already clip (Container.clipBehavior on the card,
    // or an explicit ClipRRect around the compact thumbnail), so this
    // renders unrounded and lets the parent own the corners.
    return NetworkImageBox(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.zero,
    );
  }

  Widget _buildHeart() {
    return InkWell(
      onTap: onHeartTap,
      borderRadius: BorderRadius.circular(AppRadius.round),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSaved ? Icons.favorite : Icons.favorite_border,
          color: isSaved ? AppColors.heartActive : AppColors.textSecondary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: AppColors.starFill, size: 14),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.rating,
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Formatters.currency(price),
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
        ),
        Text(
          ' /month',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
