import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/enums/verification_status.dart';
import '../../../core/enums/listing_status.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/layout/section_header.dart';
import '../../../shared/widgets/cards/stat_row_tile.dart';
import '../../../shared/widgets/cards/alert_card.dart';
import '../../../shared/widgets/cards/activity_row.dart';
import '../../../shared/widgets/layout/status_chip.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(variant: AppTopBarVariant.brand),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(),
            SizedBox(height: AppSpacing.lg),
            _buildStatRow(),
            SizedBox(height: AppSpacing.lg),
            _buildActionRow(),
            SizedBox(height: AppSpacing.lg),
            _buildVerificationAlert(),
            SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: AppStrings.recentActivity),
            SizedBox(height: AppSpacing.sm),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Obx(() {
      final name = controller.currentUser?.displayName ?? '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dashboardGreeting(name),
            style: AppTextStyles.screenTitle,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.dashboardSubtitle,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    });
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => StatRowTile(
                title: AppStrings.totalListingLabel,
                value: controller.ownerListings.length.toString(),
                trailing: const StatusChip(type: StatusChipType.active),
                icon: Icons.list_alt,
                tileColor: AppColors.secondaryContainer,
                iconColor: AppColors.secondary,
              )),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Obx(() => StatRowTile(
                title: AppStrings.totalViewsLabel,
                value: Formatters.compact(controller.totalViews),
                trailing: const StatusChip(type: StatusChipType.traffic),
                icon: Icons.visibility,
                tileColor: AppColors.primaryContainer,
                iconColor: AppColors.primaryVariant,
              )),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: AppStrings.addHostel,
            onPressed: () => controller.navigateToTab(2),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: SecondaryButton(
            text: AppStrings.viewListingButton,
            onPressed: () => controller.navigateToTab(1),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationAlert() {
    return Obx(() {
      final status = controller.currentUser?.verificationStatus ?? VerificationStatus.unverified;
      if (status == VerificationStatus.verified) return const SizedBox.shrink();
      
      // Prefer the first pending/draft listing's name, since that's what's
      // actually "under review" — falling back to any listing, then to a
      // generic name, only when nothing is pending/draft.
      final pendingOrDraft = controller.ownerListings.where(
        (h) => h.status == ListingStatus.pending || h.status == ListingStatus.draft,
      );
      final String hostelName = pendingOrDraft.isNotEmpty
          ? pendingOrDraft.first.name
          : controller.ownerListings.isNotEmpty
              ? controller.ownerListings.first.name
              : AppStrings.genericPropertyName;

      return AlertCard(
        title: AppStrings.pendingVerificationTitle,
        message: AppStrings.pendingVerificationMessage(hostelName),
      );
    });
  }

  Widget _buildRecentActivityList() {
    return Obx(() {
      final activities = controller.recentActivities;
      if (activities.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text(
              'No recent activity',
              style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
            ),
          ),
        );
      }
      return Column(
        children: activities.map((activity) => ActivityRow(
          title: activity.title,
          message: activity.message,
          timeAgo: Formatters.timeAgo(activity.createdAt),
          icon: Icons.notifications_outlined,
          imageUrl: activity.thumbnailUrl,
        )).toList(),
      );
    });
  }
}
