import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_login_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

/// Admin login screen — centered card layout for desktop web.
///
/// No sidebar/top bar (this screen is outside the admin shell). Uses
/// real AppColors/AppTextStyles tokens. No mockup exists for this screen
/// (confirmed in TASK-Phase-9.md) — built in the standard centered-card
/// language desktop admin tools use.
class AdminLoginView extends GetView<AdminLoginController> {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        AppAssets.appLogo,
                        width: 72,
                        height: 72,
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        AppStrings.adminAppTitle,
                        style: AppTextStyles.authTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.adminLoginSubtitle,
                        style: AppTextStyles.screenSubtitle,
                      ),
                      const SizedBox(height: 32),
                      // Email field
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: FieldLabel(
                          AppStrings.emailLabel,
                          style: FieldLabelStyle.auth,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FormField<String>(
                        validator: (val) =>
                            Validators.email(controller.emailController.text),
                        builder: (state) {
                          return AppTextField(
                            controller: controller.emailController,
                            hintText: AppStrings.enterEmail,
                            leadingIcon: Icons.email_outlined,
                            errorText: state.errorText,
                            onChanged: (val) {
                              state.didChange(val);
                              if (state.hasError) state.validate();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: FieldLabel(
                          AppStrings.passwordLabel,
                          style: FieldLabelStyle.auth,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FormField<String>(
                        validator: (val) => Validators.password(
                            controller.passwordController.text),
                        builder: (state) {
                          return AppPasswordField(
                            controller: controller.passwordController,
                            hintText: AppStrings.passwordLabel,
                            errorText: state.errorText,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Submit button
                      Obx(
                        () => PrimaryButton(
                          text: AppStrings.adminSignInButton,
                          onPressed: controller.submit,
                          expand: true,
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
