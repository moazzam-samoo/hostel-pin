import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/enums/amenity.dart';
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
  final String? ownerName;
  final Set<Amenity> amenities;
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
    this.ownerName,
    this.amenities = const {},
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
      case HostelCardLayout.saved:
        return _buildSaved();
      case HostelCardLayout.compact:
        return _buildCompact();
    }
  }

  Widget _buildFeatured() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: _buildImage(),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: AppTextStyles.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  _buildHeart(),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Owner : ${ownerName ?? "Awais Khokhar"}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaved() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildImage(),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildHeart(),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Owner : ${ownerName ?? "Awais Khokhar"}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: onTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Details',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    _buildRating(),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                _buildAmenitiesRow(),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _buildPrice(),
                    const Spacer(),
                    Text(
                      location.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesRow() {
    final list = <MapEntry<IconData, String>>[];
    
    bool hasGym = amenities.contains(Amenity.gym);
    bool hasSecurity = amenities.contains(Amenity.security);

    if (hasGym) {
      list.add(const MapEntry(Icons.fitness_center, 'Gym'));
    }
    if (hasSecurity) {
      list.add(const MapEntry(Icons.security, '24/7 Sec'));
    }

    if (list.length < 2) {
      for (final a in amenities) {
        if (a != Amenity.gym && a != Amenity.security) {
          final label = a == Amenity.wifi ? 'Wifi' : (a == Amenity.meals ? 'Meals' : a.title.split(' ').first);
          list.add(MapEntry(a.icon, label));
          if (list.length >= 2) break;
        }
      }
    }

    // Default fallback if hostel has no amenities specified
    if (list.isEmpty) {
      list.add(const MapEntry(Icons.fitness_center, 'Gym'));
      list.add(const MapEntry(Icons.security, '24/7 Sec'));
    }

    return Row(
      children: [
        for (int i = 0; i < list.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.md),
          Icon(list[i].key, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(list[i].value, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ],
    );
  }

  Widget _buildImage() {
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
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isSaved ? Icons.favorite : Icons.favorite_border,
          color: isSaved ? AppColors.heartActive : AppColors.textSecondary,
          size: 20,
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
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '/mnth',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
