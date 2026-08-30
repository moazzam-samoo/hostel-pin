import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import '../verification_controller.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/inputs/dotted_upload_box.dart';
import '../../../../shared/widgets/feedback/instruction_box.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../core/constants/app_strings.dart';

class Step2Identity extends GetView<VerificationController> {
  const Step2Identity({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSelfieMode.value) {
        return _buildSelfieView();
      }
      return _buildCnicView();
    });
  }

  Widget _buildCnicView() {
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
                  'Verify Your Identity',
                  style: AppTextStyles.screenTitle,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Upload your identity document so we can confirm that you are a real person.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.xl),
                Text('CNIC / National ID', style: AppTextStyles.formSectionTitle.copyWith(color: AppColors.textPrimary)),
                SizedBox(height: AppSpacing.md),
                Obx(() => DottedUploadBox(
                      title: 'Front Side',
                      subtitle: 'Upload Image',
                      icon: Icons.upload_file,
                      uploadedFile: _getUploadedFile(controller.cnicFrontPath.value, controller.cnicFrontUploaded.value),
                      onTap: () => controller.captureDocumentImage(controller.cnicFrontPath, controller.cnicFrontUploaded),
                    )),
                SizedBox(height: AppSpacing.md),
                Obx(() => DottedUploadBox(
                      title: 'Back Side',
                      subtitle: 'Upload Image',
                      icon: Icons.upload_file,
                      uploadedFile: _getUploadedFile(controller.cnicBackPath.value, controller.cnicBackUploaded.value),
                      onTap: () => controller.captureDocumentImage(controller.cnicBackPath, controller.cnicBackUploaded),
                    )),
                SizedBox(height: AppSpacing.xl),
                const InstructionBox(
                  instructions: [
                    'Clear document and readable text',
                    'All 4 corners must be visible',
                    'Document must not be expired',
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                Obx(() {
                  bool hasFront = controller.cnicFrontPath.value.isNotEmpty || controller.cnicFrontUploaded.value;
                  bool hasBack = controller.cnicBackPath.value.isNotEmpty || controller.cnicBackUploaded.value;
                  if (hasFront && hasBack) {
                    return const StatusBox(text: 'Documents Uploaded', isSuccess: true);
                  }
                  return const StatusBox(text: 'Status: Pending Verification (Waiting for upload)', isError: true);
                }),
              ],
            ),
          ),
        ),
        _buildBottomAction(
          text: AppStrings.continueButton,
          onPressed: () {
            bool hasFront = controller.cnicFrontPath.value.isNotEmpty || controller.cnicFrontUploaded.value;
            bool hasBack = controller.cnicBackPath.value.isNotEmpty || controller.cnicBackUploaded.value;
            if (!hasFront || !hasBack) {
              AppSnackbar.showGlobal(
                message: AppStrings.errorNoIdentityDocuments,
                type: SnackbarType.error,
              );
              return;
            }
            controller.isSelfieMode.value = true;
          },
        ),
      ],
    );
  }

  Widget _buildSelfieView() {
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
                  'Confirm Your Identity',
                  style: AppTextStyles.screenTitle,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Take a selfie to confirm that you are the person shown on your identity document.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 48.h),
                Center(
                  child: GestureDetector(
                    onTap: () => controller.captureImage(controller.selfiePath, controller.selfieUploaded),
                    child: Obx(() {
                      bool hasSelfie = controller.selfiePath.value.isNotEmpty;
                      bool isUploaded = controller.selfieUploaded.value;

                      return DottedBorder(
                        options: const CircularDottedBorderOptions(
                          color: AppColors.primary,
                          strokeWidth: 3,
                          dashPattern: [8, 8],
                        ),
                        child: Container(
                          width: 240.w,
                          height: 240.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceTonal,
                            image: hasSelfie
                                ? DecorationImage(
                                    image: FileImage(File(controller.selfiePath.value)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (!hasSelfie && !isUploaded)
                              ? Center(
                                  child: Icon(
                                    Icons.face,
                                    size: 64.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : (!hasSelfie && isUploaded)
                                  ? Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 64.sp,
                                        color: AppColors.success,
                                      ),
                                    )
                                  : null,
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 48.h),
                const InfoInstructionBox(
                  text: 'Instructions: Look directly at the camera. Ensure your face is clearly visible and well-lit. Remove sunglasses or hats.',
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          bool hasSelfie = controller.selfiePath.value.isNotEmpty || controller.selfieUploaded.value;
          return _buildBottomAction(
            text: hasSelfie ? 'Continue' : 'Take Selfie',
            icon: hasSelfie ? null : const Icon(Icons.camera_alt, color: AppColors.background),
            isLoading: controller.isLoading.value,
            onPressed: () {
              if (!hasSelfie) {
                controller.captureImage(controller.selfiePath, controller.selfieUploaded);
              } else {
                controller.nextStep(); // Goes to next major step (Hostel Info)
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildBottomAction({required String text, Widget? icon, required VoidCallback onPressed, bool isLoading = false}) {
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
        child: PrimaryButton(
          text: text,
          icon: icon,
          isLoading: isLoading,
          isDisabled: isLoading,
          onPressed: onPressed,
        ),
      ),
    );
  }

  File? _getUploadedFile(String path, bool isUploaded) {
    if (path.isNotEmpty) return File(path);
    if (isUploaded) return File(''); // Dummy file to indicate uploaded state without a local path
    return null;
  }
}
