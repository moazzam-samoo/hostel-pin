import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_listing_controller.dart';
import 'widgets/image_upload_section.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/layout/keyboard_dismiss_wrapper.dart';
import '../../../shared/widgets/layout/form_section_header.dart';
import '../../../shared/widgets/feedback/confirm_dialog.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/inputs/amenity_selector.dart';
import '../../../shared/widgets/inputs/app_switch.dart';
import '../../../core/enums/availability_status.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/media/map_panel.dart';

class AddListingView extends GetView<AddListingController> {
  // Distinguishes the Owner Shell's long-lived "Add" tab instance (untagged,
  // registered once by OwnerShellBinding, alive for the whole shell session)
  // from a one-off Edit session (tagged 'edit', registered fresh per push at
  // Routes.ownerEdit). Both used to share one untagged AddListingController
  // singleton — since IndexedStack builds all shell tabs eagerly, the blank
  // Add tab claimed it first, so opening Edit reused that same
  // already-initialized instance instead of a fresh one populated from the
  // real HostelModel, and any location/form state set in one bled into the
  // other. See app_pages.dart's Routes.ownerEdit registration.
  //
  // This is GetX's own documented pattern for a tagged GetView (see
  // get_view.dart's doc comment); GetView.controller already does
  // `GetInstance().find<T>(tag: tag)`, so overriding this field is how the
  // tag reaches it, not a mistake. NOTE: `super.tag` does NOT work here —
  // GetView's constructor (installed version 4.7.3) only accepts `key`,
  // not `tag`, so that shorthand is a real compile error.
  @override
  // ignore: overridden_fields
  final String? tag;

  const AddListingView({super.key, this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddListingController>(
      tag: tag,
      builder: (_) => PopScope(
        canPop: !controller.hasUnsavedChanges,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _confirmDiscard();
        },
        child: Scaffold(
          appBar: AppTopBar(
            variant: AppTopBarVariant.titled,
            title: controller.isEditMode
                ? AppStrings.editListingTitle
                : AppStrings.listPropertyTitle,
          ),
          body: KeyboardDismissWrapper(
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.gutter),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppStrings.listPropertySubtitle,
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: AppSpacing.lg),

                          // 1. Identity & Location
                          const FormSectionHeader(
                              title: AppStrings.identityLocationSection),
                          SizedBox(height: AppSpacing.md),
                          _buildValidatedField(
                            label: AppStrings.hostelNameLabel,
                            controller: controller.nameController,
                            hintText: AppStrings.hostelNameHint,
                            validator: Validators.required,
                          ),
                          SizedBox(height: AppSpacing.md),
                          _buildValidatedField(
                            label: AppStrings.fullAddressLabel,
                            controller: controller.addressController,
                            hintText: AppStrings.fullAddressHint,
                            validator: Validators.required,
                          ),
                          SizedBox(height: AppSpacing.md),
                          _buildValidatedField(
                            label: AppStrings.descriptionLabel,
                            controller: controller.descriptionController,
                            hintText: AppStrings.descriptionHint,
                            validator: Validators.required,
                            maxLines: 5,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Obx(() => MapPanel(
                                mode: MapPanelMode.picker,
                                height: 140,
                                onTap: controller.pickLocation,
                                latitude: controller.hasPickedLocation.value
                                    ? controller.latitude.value
                                    : null,
                                longitude: controller.hasPickedLocation.value
                                    ? controller.longitude.value
                                    : null,
                                label: controller.hasPickedLocation.value
                                    ? AppStrings.locationCoordinatesLabel(
                                        controller.latitude.value,
                                        controller.longitude.value)
                                    : AppStrings.tapToPinLocation,
                              )),
                          SizedBox(height: AppSpacing.xl),

                          // 2. Photos
                          const FormSectionHeader(
                              title: AppStrings.addPhotosSection),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            AppStrings.minPhotosNote,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textTertiary),
                          ),
                          SizedBox(height: AppSpacing.md),
                          ImageUploadSection(tag: tag),
                          SizedBox(height: AppSpacing.xl),

                          // 3. Rooms & Pricing
                          const FormSectionHeader(
                              title: AppStrings.roomsPricingSection),
                          SizedBox(height: AppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildValidatedField(
                                  label: AppStrings.monthlyPriceLabel,
                                  controller: controller.priceController,
                                  hintText: AppStrings.monthlyPriceLabel,
                                  keyboardType: TextInputType.number,
                                  leadingIcon: Icons.attach_money,
                                  validator: Validators.price,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _buildValidatedField(
                                  label: AppStrings.totalRoomsLabel,
                                  controller: controller.roomsController,
                                  hintText: AppStrings.roomsExample,
                                  keyboardType: TextInputType.number,
                                  validator: Validators.rooms,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.md),
                          Obx(() {
                            final isAvailable = controller.availability.value ==
                                AvailabilityStatus.available;
                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppStrings.availabilityLabel,
                                    style: AppTextStyles.body
                                        .copyWith(color: AppColors.textPrimary),
                                  ),
                                ),
                                Text(
                                  isAvailable
                                      ? AppStrings.availableStatus
                                      : AppStrings.fullStatus,
                                  style: AppTextStyles.caption.copyWith(
                                    color: isAvailable
                                        ? AppColors.success
                                        : AppColors.error,
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
                            final currentAmenities =
                                controller.selectedAmenities.toSet();
                            return AmenitySelector(
                              selectedAmenities: currentAmenities,
                              onToggle: controller.toggleAmenity,
                            );
                          }),
                          SizedBox(height: AppSpacing.xl),

                          // 4. Connectivity
                          const FormSectionHeader(
                              title: AppStrings.ownerConnectivitySection),
                          SizedBox(height: AppSpacing.md),
                          _buildValidatedField(
                            label: AppStrings.phoneNoLabel,
                            controller: controller.phoneController,
                            hintText: AppStrings.phoneHint,
                            keyboardType: TextInputType.phone,
                            leadingIcon: Icons.call,
                            validator: Validators.phone,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Obx(() => GestureDetector(
                                onTap: () => controller.sameAsPhone.toggle(),
                                child: Row(
                                  children: [
                                    Icon(
                                      controller.sameAsPhone.value
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: controller.sameAsPhone.value
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Flexible(
                                      child: Text(
                                        AppStrings.sameAsPhoneLabel,
                                        style: AppTextStyles.body,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(height: AppSpacing.md),
                          Obx(() => _buildValidatedField(
                                label: AppStrings.whatsappNumberLabel,
                                controller: controller.whatsappController,
                                hintText: AppStrings.phoneHint,
                                keyboardType: TextInputType.phone,
                                leadingIcon: Icons.chat_bubble_outline,
                                validator: Validators.phone,
                                enabled: !controller.sameAsPhone.value,
                              )),
                        ],
                      ),
                    ),
                  ),
                  _buildActionRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// FieldLabel + FormField-wrapped AppTextField, matching the pattern
  /// established by EditProfileView: the FormField owns validation state
  /// and feeds errorText back into the (otherwise dumb) AppTextField.
  Widget _buildValidatedField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    IconData? leadingIcon,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        SizedBox(height: AppSpacing.xs),
        FormField<String>(
          validator: (_) => validator(controller.text),
          builder: (state) => AppTextField(
            controller: controller,
            hintText: hintText,
            keyboardType: keyboardType,
            leadingIcon: leadingIcon,
            enabled: enabled,
            maxLines: maxLines,
            errorText: state.errorText,
            onChanged: (val) {
              state.didChange(val);
              if (state.hasError) state.validate();
            },
          ),
        ),
      ],
    );
  }

  void _confirmDiscard() {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.unsavedChangesTitle,
        message: AppStrings.unsavedChangesMessage,
        confirmText: AppStrings.discardButton,
        isDestructive: true,
        onConfirm: () {
          Get.back(); // close dialog
          Get.back(); // leave the form
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  Widget _buildActionRow() {
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
        child: Obx(() {
          // Upload + save is now async/network-dependent (Block A.6) — both
          // buttons must be disabled and the in-flight one must show a
          // spinner for the whole upload+write batch, not just the form's
          // synchronous field-validity check.
          final isSaving = controller.isLoading.value;
          return Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: AppStrings.saveAsDraft,
                  isLoading: isSaving,
                  isDisabled: isSaving,
                  onPressed: controller.saveAsDraft,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: GetBuilder<AddListingController>(
                  tag: tag,
                  builder: (c) => PrimaryButton(
                    text: c.isEditMode
                        ? AppStrings.updateListingButton
                        : AppStrings.publishListing,
                    isLoading: isSaving,
                    isDisabled: isSaving,
                    onPressed: controller.publishListing,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
