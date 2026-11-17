import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/enums/verification_status.dart';
import '../../../core/enums/listing_status.dart';
import '../shell/owner_add_access.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/layout/section_header.dart';
import '../../../shared/widgets/cards/stat_row_tile.dart';
import '../../../shared/widgets/cards/alert_card.dart';
import '../../../shared/widgets/cards/activity_row.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(variant: AppTopBarVariant.brand),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeader(),
            SizedBox(height: AppSpacing.lg),
            _buildRejectedAlerts(),
            _buildStatRow(),
            SizedBox(height: AppSpacing.lg),
            _buildActionRow(),
            SizedBox(height: AppSpacing.lg),
            _buildVerificationAlert(),
            _buildPendingPropertyAlert(),
            SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: AppStrings.recentActivity),
            SizedBox(height: AppSpacing.sm),
            Obx(() => _buildRecentActivityList()),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Obx(() {
      final name = controller.welcomeName;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dashboardWelcome(name),
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
                layout: StatRowTileLayout.card,
                title: AppStrings.totalListingLabel,
                value:
                    controller.ownerListings.length.toString().padLeft(2, '0'),
                icon: Icons.apartment_rounded,
                tileColor: AppColors.secondaryContainer,
                iconColor: AppColors.secondary,
                trailing: Text(
                  AppStrings.activeLabel,
                  style: AppTextStyles.labelMicro.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              )),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Obx(() => StatRowTile(
                layout: StatRowTileLayout.card,
                title: AppStrings.totalViewsLabel,
                value: Formatters.compact(controller.totalViews),
                icon: Icons.visibility_outlined,
                tileColor: AppColors.primaryContainer,
                iconColor: AppColors.primaryVariant,
                trailing: Text(
                  AppStrings.trafficLabel,
                  style: AppTextStyles.labelMicro.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
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
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.background, size: 20),
            onPressed: () => controller.navigateToTab(2),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: SecondaryButton(
            text: AppStrings.viewListingButton,
            icon:
                const Icon(Icons.list_alt, color: AppColors.primary, size: 20),
            onPressed: () => controller.navigateToTab(1),
          ),
        ),
      ],
    );
  }

  /// One alert per rejected hostel with the admin's reason, so the owner knows
  /// exactly what to fix before resubmitting.
  Widget _buildRejectedAlerts() {
    return Obx(() {
      final rejected = controller.rejectedListings;
      if (rejected.isEmpty) return const SizedBox.shrink();
      return Column(
        children: [
          for (final hostel in rejected)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: AlertCard(
                title: AppStrings.rejectedHostelTitle(hostel.name),
                message: (hostel.rejectionReason ?? '').trim().isEmpty
                    ? AppStrings.rejectedHostelFallbackReason
                    : hostel.rejectionReason!,
                actionLabel: AppStrings.rejectedHostelFixButton,
                onAction: () => controller.editListing(hostel),
              ),
            ),
          SizedBox(height: AppSpacing.xs),
        ],
      );
    });
  }

  Widget _buildVerificationAlert() {
    return Obx(() {
      final status = controller.currentUser?.verificationStatus ??
          VerificationStatus.unverified;
      if (status == VerificationStatus.verified) return const SizedBox.shrink();

      switch (controller.verificationAccess) {
        case OwnerAddAccess.needsVerification:
          // Nothing submitted yet: ask the owner to start, never claim a
          // review is in progress.
          return AlertCard(
            icon: Icons.verified_user_outlined,
            title: AppStrings.verifyAccountTitle,
            message: AppStrings.verifyAccountMessage,
            actionLabel: AppStrings.addTabGateButton,
            onAction: controller.startVerification,
          );
        case OwnerAddAccess.rejected:
          return AlertCard(
            title: AppStrings.verificationRejectedTitle,
            message: AppStrings.addTabRejectedMessage,
            actionLabel: AppStrings.verificationResubmitButton,
            onAction: controller.startVerification,
          );
        case OwnerAddAccess.allowed:
        case OwnerAddAccess.limitReached:
          // Submitted and waiting for the admin.
          final pending = controller.ownerListings
              .where((h) => h.status == ListingStatus.pending)
              .toList();
          return AlertCard(
            title: AppStrings.pendingVerificationTitle,
            message: pending.isNotEmpty
                ? AppStrings.pendingVerificationMessage(pending.first.name)
                : AppStrings.verificationUnderReviewMessage,
          );
      }
    });
  }

  /// Distinct from _buildVerificationAlert above (identity verification):
  /// this reacts to `controller.ownerListings` (an RxList, live via
  /// HostelRepository.streamByOwner) rather than
  /// SessionService.currentUser.value.verificationStatus, so it appears the
  /// moment ANY listing is pending — including a listing an already-fully-
  /// verified owner adds later (2.A's uniform review gate) — and disappears
  /// once every pending listing resolves (approved -> published, or
  /// rejected). Both alerts can show at once for a brand-new owner; that's
  /// expected, not a bug.
  Widget _buildPendingPropertyAlert() {
    return Obx(() {
      final pending = controller.ownerListings
          .where((h) => h.status == ListingStatus.pending)
          .toList();
      if (pending.isEmpty) return const SizedBox.shrink();

      final message = pending.length == 1
          ? AppStrings.pendingPropertyMessage(pending.first.name)
          : AppStrings.pendingPropertiesCountMessage(pending.length);

      return Padding(
        padding: EdgeInsets.only(top: AppSpacing.md),
        child: AlertCard(
          title: AppStrings.pendingPropertyTitle,
          message: message,
        ),
      );
    });
  }

  Widget _buildRecentActivityList() {
    final activities = controller.recentActivities;
    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Text(
            AppStrings.noRecentActivity,
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return Column(
      children: activities
          .map((activity) => ActivityRow(
                title: activity.title,
                message: activity.message,
                timeAgo: Formatters.timeAgo(activity.createdAt),
                icon: Icons.notifications_outlined,
                imageUrl: activity.thumbnailUrl,
              ))
          .toList(),
    );
  }
}
