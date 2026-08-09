// TODO(phone-verification): unrouted in v1, see IMPLEMENTATION_PLAN.md decision D1
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/otp_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/cards/auth_form_card.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/inputs/otp_field_row.dart';
import '../../../shared/widgets/layout/highlighted_body_text.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments as String? ?? 'your email';

    return AppScaffold(
      topBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.verifyEmailTitle,
      ),
      applyGutter: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.xl),
            AuthFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightedBodyText(
                    textBefore: AppStrings.otpSentToPrefix,
                    highlightedText: email,
                    textAfter: AppStrings.otpSentToSuffix,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  const FieldLabel(AppStrings.enterOtp,
                    style: FieldLabelStyle.auth,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  OtpFieldRow(
                    controller: controller.otpController,
                    onResend: () {},
                  ),
                  SizedBox(height: AppSpacing.md),
                  Obx(
                    () => PrimaryButton(text: AppStrings.verifyButton, onPressed: controller.verifyOtp,
                      expand: true,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
