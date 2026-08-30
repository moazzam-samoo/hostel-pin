import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'verification_controller.dart';
import '../../../core/enums/verification_step.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/navigation/verification_breadcrumb.dart';
import '../../../shared/widgets/layout/keyboard_dismiss_wrapper.dart';
import 'steps/step1_personal_info.dart';
import 'steps/step2_identity.dart';
import 'steps/step3_hostel_info.dart';
import 'steps/step4_documents.dart';
import 'steps/step5_review.dart';
import 'steps/step6_submission.dart';

class VerificationWizardView extends GetView<VerificationController> {
  const VerificationWizardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        variant: AppTopBarVariant.titled,
        title: 'Owner Verification',
        onBack: () => Get.back(),
        actions: [
          Center(
            child: Obx(() {
              const steps = VerificationStep.values;
              final currentIndex = steps.indexOf(controller.currentStep.value);
              // Only show Step X of 5 if we are in the main 5 steps
              if (currentIndex < 5) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Step ${currentIndex + 1} of 5',
                    style: AppTextStyles.labelMicro.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ],
      ),
      body: KeyboardDismissWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The breadcrumb stepper
            Obx(() {
              if (controller.currentStep.value == VerificationStep.submission) {
                return const SizedBox.shrink(); // No stepper on submission screen
              }
              const steps = VerificationStep.values;
              final currentIndex = steps.indexOf(controller.currentStep.value);
              return VerificationBreadcrumb(
                currentStep: currentIndex + 1,
              );
            }),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                switch (controller.currentStep.value) {
                  case VerificationStep.personalInfo:
                    return const Step1PersonalInfo();
                  case VerificationStep.identity:
                    return const Step2Identity();
                  case VerificationStep.hostelInfo:
                    return const Step3HostelInfo();
                  case VerificationStep.documents:
                    return const Step4Documents();
                  case VerificationStep.review:
                    return const Step5Review();
                  case VerificationStep.submission:
                    return const Step6Submission();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
