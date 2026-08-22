import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/change_password_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/cards/auth_form_card.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.changePasswordTitle,
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
                    const FieldLabel(
                      AppStrings.newPasswordLabel,
                      style: FieldLabelStyle.auth,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    FormField<String>(
                      validator: (val) => Validators.password(
                          controller.newPasswordController.text),
                      builder: (state) => AppPasswordField(
                        controller: controller.newPasswordController,
                        hintText: AppStrings.newPasswordLabel,
                        errorText: state.errorText,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    const FieldLabel(
                      AppStrings.confirmPasswordFieldLabel,
                      style: FieldLabelStyle.auth,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    FormField<String>(
                      validator: (val) => Validators.confirmPassword(
                        controller.confirmPasswordController.text,
                        controller.newPasswordController.text,
                      ),
                      builder: (state) => AppPasswordField(
                        controller: controller.confirmPasswordController,
                        hintText: AppStrings.confirmPasswordFieldLabel,
                        errorText: state.errorText,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Obx(
                      () => PrimaryButton(
                        text: AppStrings.changePasswordButton,
                        onPressed: controller.changePassword,
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
