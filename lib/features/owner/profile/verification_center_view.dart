import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/media/upload_placeholder.dart';
import '../../../shared/widgets/layout/status_chip.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../core/enums/verification_status.dart';

class VerificationCenterView extends StatelessWidget {
  const VerificationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<MockDataService>().currentUser.value;
    final status = user?.verificationStatus ?? VerificationStatus.unverified;
    
    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.verificationCenterTitle,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.verificationCenterSubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text(
                  AppStrings.currentStatusLabel,
                  style: AppTextStyles.cardTitle,
                ),
                SizedBox(width: AppSpacing.sm),
                _buildStatusChip(status),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.uploadDocumentLabel,
              style: AppTextStyles.cardTitle,
            ),
            SizedBox(height: AppSpacing.md),
            UploadPlaceholder(onTap: () {}),
            SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.verificationDocumentHint,
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.unverified:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            AppStrings.verificationStatusUnverified,
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        );
      case VerificationStatus.pending:
        return const StatusChip(type: StatusChipType.pending);
      case VerificationStatus.verified:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            AppStrings.verificationStatusVerified,
            style: AppTextStyles.caption.copyWith(color: AppColors.success),
          ),
        );
    }
  }
}
