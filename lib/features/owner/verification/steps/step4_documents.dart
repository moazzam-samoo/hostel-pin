import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../verification_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/inputs/dotted_upload_box.dart';
import '../../../../shared/widgets/feedback/instruction_box.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/field_label.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class Step4Documents extends GetView<VerificationController> {
  const Step4Documents({super.key});

  @override
  Widget build(BuildContext context) {
    // For UI compliance with the mockup
    final List<String> docTypes = ['Property Deed', 'Rent Agreement', 'Utility Bill'];
    final RxString selectedDocType = docTypes.first.obs;

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
                  'Hostel Verification',
                  style: AppTextStyles.screenTitle,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Please provide legal documents to prove ownership or management rights.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.xl),
                
                // Document Type Dropdown
                const FieldLabel('Document Type'),
                SizedBox(height: AppSpacing.xs),
                Obx(() => Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTonal,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDocType.value,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                          onChanged: (String? newValue) {
                            if (newValue != null) selectedDocType.value = newValue;
                          },
                          items: docTypes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: AppTextStyles.body),
                            );
                          }).toList(),
                        ),
                      ),
                    )),
                SizedBox(height: AppSpacing.md),

                // Hostel Name
                const FieldLabel('Hostel Name (Must match document)'),
                SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: controller.hostelNameController,
                  hintText: 'Enter hostel name exactly as on document',
                  leadingIcon: Icons.business,
                  enabled: false, // It's bound to the previous step's input
                ),
                SizedBox(height: AppSpacing.lg),

                // Upload Box
                Obx(() => DottedUploadBox(
                      title: 'Upload Document',
                      subtitle: 'PDF, JPG, PNG (Max 5MB)',
                      icon: Icons.upload_file,
                      uploadedFile: _getUploadedFile(controller.ownershipDocPath.value, controller.ownershipDocUploaded.value),
                      onTap: () => controller.captureDocumentImage(controller.ownershipDocPath, controller.ownershipDocUploaded),
                    )),
                
                SizedBox(height: AppSpacing.xl),
                
                const InstructionBox(
                  instructions: [
                    'Document must be issued within the last 6 months',
                    'All pages must be included',
                    'Name must match your registered business name',
                  ],
                ),
              ],
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

  File? _getUploadedFile(String path, bool isUploaded) {
    if (path.isNotEmpty) return File(path);
    if (isUploaded) return File('');
    return null;
  }
}
