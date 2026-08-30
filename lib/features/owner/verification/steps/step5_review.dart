import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../verification_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/verification_step.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class Step5Review extends GetView<VerificationController> {
  const Step5Review({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.reviewStepTitle,
                  style: AppTextStyles.screenTitle,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.reviewStepSubtitle,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.xl),
                _buildSectionCard(
                  title: AppStrings.personalInfoSectionTitle,
                  icon: Icons.person_outline,
                  onEdit: () => controller.editStep(VerificationStep.personalInfo),
                  children: [
                    _buildReviewRow(AppStrings.reviewLabelName, controller.fullNameController.text),
                    _buildReviewRow(AppStrings.phoneLabel, controller.phoneController.text),
                    _buildReviewRow(AppStrings.reviewLabelCnic, controller.cnicController.text),
                    _buildReviewRow('City', controller.cityController.text),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Obx(() => _buildSectionCard(
                      title: 'Identity',
                      icon: Icons.badge_outlined,
                      onEdit: () => controller.editStep(VerificationStep.identity),
                      children: [
                        _buildStatusRow(
                          icon: Icons.credit_card_outlined,
                          label: 'CNIC Front & Back',
                          isCompleted: controller.cnicFrontPath.value.isNotEmpty || controller.cnicFrontUploaded.value,
                          usePill: true,
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildStatusRow(
                          icon: Icons.face,
                          label: 'Selfie Verification',
                          isCompleted: controller.selfiePath.value.isNotEmpty || controller.selfieUploaded.value,
                          usePill: true,
                        ),
                      ],
                    )),
                SizedBox(height: AppSpacing.md),
                Obx(() => _buildSectionCard(
                      title: AppStrings.hostelInfoSectionTitle,
                      icon: Icons.business_outlined,
                      onEdit: () => controller.editStep(VerificationStep.hostelInfo),
                      children: [
                        _buildReviewRow(AppStrings.reviewLabelName, controller.hostelNameController.text),
                        _buildReviewRow('City', controller.resolvedCity.value.isNotEmpty ? controller.resolvedCity.value : _fallbackCity(controller.hostelAddressController.text)),
                        _buildReviewRow(AppStrings.reviewLabelAddress, controller.hostelAddressController.text),
                        _buildReviewRow('Rooms', controller.hostelRoomsController.text),
                        _buildReviewRow('Total Beds', controller.hostelBedsController.text),
                      ],
                    )),
                SizedBox(height: AppSpacing.md),
                Obx(() => _buildSectionCard(
                      title: 'Hostel Verification',
                      icon: Icons.verified_user_outlined,
                      onEdit: () => controller.editStep(VerificationStep.documents),
                      children: [
                        _buildStatusRow(
                          icon: Icons.description_outlined,
                          label: AppStrings.reviewLabelOwnershipDoc,
                          isCompleted: controller.ownershipDocPath.value.isNotEmpty || controller.ownershipDocUploaded.value,
                          usePill: false,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _buildStatusRow(
                          icon: Icons.camera_alt_outlined,
                          label: 'Exterior Photos',
                          isCompleted: controller.photos.length >= 3,
                          usePill: false,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        _buildStatusRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location Pinned',
                          isCompleted: controller.hasPickedLocation.value,
                          usePill: false,
                        ),
                      ],
                    )),
                SizedBox(height: AppSpacing.xl),
                Obx(() => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: controller.policyAccepted.value,
                            onChanged: (value) => controller.policyAccepted.value = value ?? false,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(color: AppColors.border, width: 1.5),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            AppStrings.reviewPolicyText,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        _buildBottomAction(
          text: AppStrings.submitForVerificationButton,
          onPressed: () => controller.submitVerification(),
        ),
      ],
    );
  }

  String _fallbackCity(String address) {
    if (address.isEmpty) return AppStrings.defaultCityFallback;
    final parts = address.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.last : AppStrings.defaultCityFallback;
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.sectionHeader.copyWith(fontSize: 16),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.editButton,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: isAlert ? AppColors.error : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool usePill,
  }) {
    if (usePill) {
      return Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Completed',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Missing',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
        ],
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceTonal,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 24),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20)
            else
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          ],
        ),
      );
    }
  }

  Widget _buildBottomAction({required String text, required VoidCallback onPressed}) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.gutter),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => PrimaryButton(
              text: text,
              isLoading: controller.isLoading.value,
              isDisabled: controller.isLoading.value || !controller.policyAccepted.value,
              onPressed: onPressed,
            )),
      ),
    );
  }
}
