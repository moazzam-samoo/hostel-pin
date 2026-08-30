import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../verification_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/availability_status.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/inputs/validated_text_field.dart';
import '../../../../shared/widgets/inputs/field_label.dart';
import '../../../../shared/widgets/inputs/amenity_selector.dart';
import '../../../../shared/widgets/inputs/app_switch.dart';
import '../../../../shared/widgets/layout/form_section_header.dart';
import '../../../../shared/widgets/media/image_upload_section.dart';
import '../../../../shared/widgets/media/map_panel.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

/// Wizard step 3 — the owner's real first listing (D.2/D.6). Reuses the
/// same shared, controller-agnostic widgets AddListingView already uses
/// (ValidatedTextField, AmenitySelector, ImageUploadSection, MapPanel)
/// rather than forking a copy, per Block D.3's reuse decision. Collects
/// every field AddListingController does, plus totalBeds and — critically —
/// photos (minimum 3): without this section a hostel created by this wizard
/// could never satisfy AddListingController.isValid's same photo-count gate.
class Step3HostelInfo extends GetView<VerificationController> {
  const Step3HostelInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.gutter),
            child: Form(
        key: controller.hostelInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.hostelInfoStepTitle,
              style: AppTextStyles.screenTitle,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.hostelInfoStepSubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.xl),

            const FormSectionHeader(title: AppStrings.identityLocationSection),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.hostelNameLabel,
              controller: controller.hostelNameController,
              hintText: AppStrings.hostelNameHint,
              validator: Validators.required,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.fullAddressLabel,
              controller: controller.hostelAddressController,
              hintText: AppStrings.fullAddressHint,
              validator: Validators.required,
              maxLines: 3,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.descriptionLabel,
              controller: controller.hostelDescriptionController,
              hintText: AppStrings.descriptionHint,
              validator: Validators.required,
              maxLines: 5,
            ),
            SizedBox(height: AppSpacing.md),
            Obx(() => MapPanel(
                  mode: MapPanelMode.picker,
                  height: 140,
                  onTap: controller.pickLocation,
                  latitude: controller.hasPickedLocation.value ? controller.latitude.value : null,
                  longitude: controller.hasPickedLocation.value ? controller.longitude.value : null,
                  label: controller.hasPickedLocation.value
                      ? AppStrings.locationCoordinatesLabel(
                          controller.latitude.value, controller.longitude.value)
                      : AppStrings.tapToPinLocation,
                )),
            SizedBox(height: AppSpacing.xl),

            const FormSectionHeader(title: AppStrings.addPhotosSection),
            SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.minPhotosNote,
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
            SizedBox(height: AppSpacing.md),
            Obx(() => ImageUploadSection(
                  photos: controller.photos.toList(),
                  onPickImages: controller.pickHostelPhotos,
                  onRemovePhoto: controller.removeHostelPhoto,
                )),
            SizedBox(height: AppSpacing.xl),

            const FormSectionHeader(title: AppStrings.roomsPricingSection),
            SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ValidatedTextField(
                    label: AppStrings.monthlyPriceLabel,
                    controller: controller.hostelPriceController,
                    hintText: AppStrings.monthlyPriceLabel,
                    keyboardType: TextInputType.number,
                    leadingIcon: Icons.attach_money,
                    validator: Validators.price,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ValidatedTextField(
                    label: AppStrings.totalRoomsLabel,
                    controller: controller.hostelRoomsController,
                    hintText: AppStrings.roomsExample,
                    keyboardType: TextInputType.number,
                    validator: Validators.rooms,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.totalBedsLabel,
              controller: controller.hostelBedsController,
              hintText: AppStrings.bedsExample,
              keyboardType: TextInputType.number,
              validator: Validators.beds,
            ),
            SizedBox(height: AppSpacing.md),
            Obx(() {
              final isAvailable = controller.availability.value == AvailabilityStatus.available;
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.availabilityLabel,
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    isAvailable ? AppStrings.availableStatus : AppStrings.fullStatus,
                    style: AppTextStyles.caption.copyWith(
                      color: isAvailable ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSwitch(
                    value: isAvailable,
                    onChanged: controller.toggleAvailability,
                  ),
                ],
              );
            }),
            SizedBox(height: AppSpacing.md),
            const FieldLabel(AppStrings.includedFacilitiesLabel),
            SizedBox(height: AppSpacing.sm),
            Obx(() {
              final currentAmenities = controller.selectedAmenities.toSet();
              return AmenitySelector(
                selectedAmenities: currentAmenities,
                onToggle: controller.toggleAmenity,
              );
            }),
            SizedBox(height: AppSpacing.xl),

            const FormSectionHeader(title: AppStrings.ownerConnectivitySection),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.phoneNoLabel,
              controller: controller.hostelPhoneController,
              hintText: AppStrings.phoneHint,
              keyboardType: TextInputType.phone,
              leadingIcon: Icons.call,
              validator: Validators.phone,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.whatsappNumberLabel,
              controller: controller.hostelWhatsappController,
              hintText: AppStrings.phoneHint,
              keyboardType: TextInputType.phone,
              leadingIcon: Icons.chat_bubble_outline,
              validator: Validators.phone,
            ),
          ],
        ),
      ),
    ),
    ),
    _buildBottomAction(
      text: 'Continue',
      isLoading: controller.isLoading.value,
      onPressed: () => controller.nextStep(),
    ),
    ],
    );
  }

  Widget _buildBottomAction({required String text, required VoidCallback onPressed, bool isLoading = false}) {
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
          isDisabled: controller.isLoading.value,
          onPressed: onPressed,
        )),
      ),
    );
  }
}
