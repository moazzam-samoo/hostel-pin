import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/forgot_password_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/cards/auth_form_card.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.forgotPassword,
      ),
      applyGutter: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.xl),
            AuthFormCard(
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(AppStrings.emailLabel,
                      style: FieldLabelStyle.auth,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    FormField<String>(
                      validator: (val) => Validators.email(controller.emailController.text),
                      builder: (state) => AppTextField(
                        controller: controller.emailController,
                        hintText: AppStrings.enterEmail,
                        leadingIcon: Icons.email_outlined,
                        errorText: state.errorText,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) {
                          state.didChange(val);
                          if (state.hasError) state.validate();
                        },
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Obx(
                      () => PrimaryButton(text: AppStrings.sendResetLink, onPressed: controller.sendResetLink,
                        expand: true,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
