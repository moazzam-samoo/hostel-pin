import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/signup_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/layout/auth_hero_sheet.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/google_auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer_prompt.dart';
import '../widgets/terms_checkbox.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryVariant,
      body: AuthHeroSheet(
        showBack: true,
        onBack: () => Get.back(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.signup,
                  style: AppTextStyles.authTitle,
                ),
                SizedBox(height: AppSpacing.lg),

                // Full Name
                const FieldLabel(
                  AppStrings.fullNameLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) =>
                      Validators.required(controller.nameController.text),
                  builder: (state) => AppTextField(
                    controller: controller.nameController,
                    hintText: AppStrings.fullNameLabel,
                    leadingIcon: Icons.person_outline,
                    errorText: state.errorText,
                    onChanged: (val) {
                      state.didChange(val);
                      if (state.hasError) state.validate();
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Email
                const FieldLabel(
                  AppStrings.emailLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) =>
                      Validators.email(controller.emailController.text),
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
                SizedBox(height: AppSpacing.md),

                // Phone
                const FieldLabel(
                  AppStrings.phoneLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) =>
                      Validators.phone(controller.phoneController.text),
                  builder: (state) => AppTextField(
                    controller: controller.phoneController,
                    hintText: AppStrings.phoneLabel,
                    leadingIcon: Icons.phone_outlined,
                    errorText: state.errorText,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {
                      state.didChange(val);
                      if (state.hasError) state.validate();
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Password
                const FieldLabel(
                  AppStrings.passwordLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) =>
                      Validators.password(controller.passwordController.text),
                  builder: (state) => AppPasswordField(
                    controller: controller.passwordController,
                    hintText: AppStrings.passwordLabel,
                    errorText: state.errorText,
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Confirm Password
                const FieldLabel(
                  AppStrings.confirmPasswordLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) => Validators.confirmPassword(
                    controller.confirmPasswordController.text,
                    controller.passwordController.text,
                  ),
                  builder: (state) => AppPasswordField(
                    controller: controller.confirmPasswordController,
                    hintText: AppStrings.confirmPasswordLabel,
                    errorText: state.errorText,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Terms
                Obx(() => TermsCheckbox(
                      value: controller.acceptedTerms.value,
                      onChanged: (val) =>
                          controller.acceptedTerms.value = val ?? false,
                    )),
                SizedBox(height: AppSpacing.xl),

                Obx(
                  () => PrimaryButton(
                    text: AppStrings.createAccount,
                    onPressed: controller.submit,
                    expand: true,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                const AuthDivider(),
                SizedBox(height: AppSpacing.xl),
                Center(
                    child:
                        GoogleAuthButton(isLoading: false, onPressed: () {})),
                SizedBox(height: AppSpacing.xl),
                AuthFooterPrompt(
                  promptText: "Already have an account?",
                  actionText: "Login",
                  onPressed: () => Get.back(),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
