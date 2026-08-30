import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../verification_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../shared/widgets/inputs/validated_text_field.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class Step1PersonalInfo extends GetView<VerificationController> {
  const Step1PersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.gutter),
            child: Form(
        key: controller.personalInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.personalInfoStepTitle,
              style: AppTextStyles.screenTitle,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.personalInfoStepSubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.xl),
            ValidatedTextField(
              label: AppStrings.fullNameLabel,
              controller: controller.fullNameController,
              hintText: AppStrings.fullNameHint,
              validator: Validators.required,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.guardianNameLabel,
              controller: controller.guardianNameController,
              hintText: AppStrings.guardianNameHint,
              validator: Validators.required,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.cnicNumberLabel,
              controller: controller.cnicController,
              hintText: AppStrings.cnicNumberHint,
              keyboardType: TextInputType.number,
              inputFormatters: [CnicInputFormatter()],
              validator: Validators.cnic,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.dobLabel,
              controller: controller.dobController,
              hintText: AppStrings.dobHint,
              readOnly: true,
              onTap: () => controller.pickDateOfBirth(context),
              validator: Validators.dateOfBirth,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.phoneNoLabel,
              controller: controller.phoneController,
              hintText: AppStrings.phoneHint,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.emailAddressLabel,
              controller: controller.emailController,
              hintText: AppStrings.emailAddressHint,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            SizedBox(height: AppSpacing.md),
            ValidatedTextField(
              label: AppStrings.cityFieldLabel,
              controller: controller.cityController,
              hintText: AppStrings.cityFieldHint,
              validator: Validators.required,
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
