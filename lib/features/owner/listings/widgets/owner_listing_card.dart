import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/listing_status.dart';
import '../../../../shared/widgets/media/network_image_box.dart';

class OwnerListingCard extends StatelessWidget {
  final HostelModel hostel;

  const OwnerListingCard({super.key, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkImageBox(
            imageUrl: hostel.photos.isNotEmpty ? hostel.photos.first : '',
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostel.name,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(hostel.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    hostel.status.name.capitalizeFirst ?? hostel.status.name,
                    style: AppTextStyles.caption.copyWith(
                      color: _getStatusColor(hostel.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.currency(hostel.pricePerMonth),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.priceMonthSuffix,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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

  Color _getStatusColor(ListingStatus status) {
    switch (status) {
      case ListingStatus.published:
        return AppColors.success;
      case ListingStatus.pending:
        return AppColors.secondary;
      case ListingStatus.draft:
        return AppColors.textSecondary;
      case ListingStatus.rejected:
        return AppColors.error;
    }
  }
}
