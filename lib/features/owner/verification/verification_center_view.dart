import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'verification_controller.dart';
import '../../../core/enums/verification_step.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/verification_task_card.dart';
import '../../../shared/widgets/feedback/instruction_box.dart';
import 'verification_wizard_view.dart';

class VerificationCenterView extends GetView<VerificationController> {
  const VerificationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.verificationCenterTitle,
      ),
      body: Obx(() {
        final completedCount = controller.completedStepsCount;
        const totalSteps = 5;
        
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Account Verification',
                      style: AppTextStyles.screenTitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Complete these steps to start listing your hostel on HostelPin.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Reviewer feedback — shown when an admin rejected the
                    // submission or asked for changes, so the owner knows why.
                    ..._buildReviewFeedback(),

                    // Progress Card
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'VERIFICATION PROGRESS',
                                style: AppTextStyles.labelMicro.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$completedCount of $totalSteps completed',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: completedCount / totalSteps,
                            backgroundColor: AppColors.surfaceTonal,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 8.h,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: AppSpacing.lg),
                    
                    // Tasks
                    VerificationTaskCard(
                      title: 'Personal Information',
                      subtitle: 'Basic details about you as the owner.',
                      icon: Icons.person_outline,
                      status: controller.personalInfoStatus,
                      onTap: () {
                        controller.currentStep.value = VerificationStep.personalInfo;
                        Get.to(() => const VerificationWizardView());
                      },
                    ),
                    VerificationTaskCard(
                      title: 'Identity Verification',
                      subtitle: 'Upload government-issued ID.',
                      icon: Icons.badge_outlined,
                      status: controller.identityStatus,
                      onTap: controller.personalInfoStatus == VerificationTaskStatus.completed
                          ? () {
                              controller.currentStep.value = VerificationStep.identity;
                              Get.to(() => const VerificationWizardView());
                            }
                          : null,
                    ),
                    VerificationTaskCard(
                      title: 'Hostel Information',
                      subtitle: 'Location, name, and basic details.',
                      icon: Icons.business_outlined,
                      status: controller.hostelInfoStatus,
                      onTap: controller.identityStatus == VerificationTaskStatus.completed
                          ? () {
                              controller.currentStep.value = VerificationStep.hostelInfo;
                              Get.to(() => const VerificationWizardView());
                            }
                          : null,
                    ),
                    VerificationTaskCard(
                      title: 'Hostel Documents',
                      subtitle: 'Licenses, tax info, and legal documents.',
                      icon: Icons.description_outlined,
                      status: controller.documentsStatus,
                      onTap: controller.hostelInfoStatus == VerificationTaskStatus.completed
                          ? () {
                              controller.currentStep.value = VerificationStep.documents;
                              Get.to(() => const VerificationWizardView());
                            }
                          : null,
                    ),
                    VerificationTaskCard(
                      title: 'Final Review',
                      subtitle: 'Submit your profile for admin review.',
                      icon: Icons.fact_check_outlined,
                      status: controller.reviewStatus,
                      onTap: controller.documentsStatus == VerificationTaskStatus.completed
                          ? () {
                              if (controller.reviewStatus == VerificationTaskStatus.pending ||
                                  controller.reviewStatus == VerificationTaskStatus.completed) {
                                controller.currentStep.value = VerificationStep.submission;
                              } else {
                                controller.currentStep.value = VerificationStep.review;
                              }
                              Get.to(() => const VerificationWizardView());
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            
            // Start Verification Button
            Container(
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
                  text: 'Start Verification',
                  onPressed: () {
                    // Start from the first incomplete step
                    if (controller.personalInfoStatus != VerificationTaskStatus.completed) {
                      controller.currentStep.value = VerificationStep.personalInfo;
                    } else if (controller.identityStatus != VerificationTaskStatus.completed) {
                      controller.currentStep.value = VerificationStep.identity;
                    } else if (controller.hostelInfoStatus != VerificationTaskStatus.completed) {
                      controller.currentStep.value = VerificationStep.hostelInfo;
                    } else if (controller.documentsStatus != VerificationTaskStatus.completed) {
                      controller.currentStep.value = VerificationStep.documents;
                    } else {
                      controller.currentStep.value = VerificationStep.review;
                    }
                    Get.to(() => const VerificationWizardView());
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildReviewFeedback() {
    final data = controller.verificationData.value;
    final status = data?.status;
    if (status != 'rejected' && status != 'changesRequested') {
      return const [];
    }
    final reason = (data?.rejectionReason ?? '').trim();
    final headline = status == 'rejected'
        ? AppStrings.verificationRejectedNotice
        : AppStrings.verificationChangesNotice;
    return [
      StatusBox(
        isError: true,
        text: reason.isEmpty
            ? headline
            : '$headline\n${AppStrings.rejectionReasonTitle}: $reason',
      ),
      SizedBox(height: AppSpacing.lg),
    ];
  }
}
