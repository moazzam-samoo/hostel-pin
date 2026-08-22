import 'package:flutter/material.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/layout/price_label.dart';
import '../../../../shared/widgets/media/network_image_box.dart';
import '../../../../shared/widgets/layout/status_chip.dart';
import '../../../../core/enums/listing_status.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Phase 5 decision (TASK-Phase-5.md Block C, finding #10): OwnerListingCard
// stays a separate, feature-scoped card rather than being merged into the
// shared HostelCard. TASK-Phase-4.md Block G explicitly authorized a
// dedicated owner card for fields HostelCard has no layout for (the status
// badge, the lavender surface, the "Location : {address}" line); forcing a
// merge would mean bolting owner-only concerns onto the canonical student
// card. Its price now routes through the shared PriceLabel widget (via
// priceStyle/suffixStyle overrides) rather than a fourth, undocumented
// inline format — see PriceLabel's row in AGENTS.md §3.
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
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: NetworkImageBox(
                  imageUrl: hostel.photos.isNotEmpty ? hostel.photos.first : '',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left:
                    12, // Positioned on the left is common for status, or right? Let's use right
                right: 12, // Usually top right or left, I'll align it right
                child: Align(
                  alignment: Alignment.topRight,
                  child: StatusChip(
                    type: hostel.status == ListingStatus.published
                        ? StatusChipType.active
                        : hostel.status == ListingStatus.pending
                            ? StatusChipType.pending
                            : StatusChipType.traffic,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  hostel.name,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PriceLabel(
                price: hostel.pricePerMonth,
                suffix: '/month',
                priceStyle: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                suffixStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Location : ${hostel.fullAddress}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
