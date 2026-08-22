import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/layout/auth_hero_sheet.dart';
import '../../../shared/widgets/media/confetti_dots.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/buttons/text_link_button.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/google_auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer_prompt.dart';
import '../../../core/theme/app_colors.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryVariant,
      body: AuthHeroSheet(
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
                  AppStrings.welcomeBack,
                  style: AppTextStyles.authTitle,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.labelSentence,
                ),
                SizedBox(height: AppSpacing.lg),
                Center(
                  child: ConfettiDots(
                    child: Image.asset(
                      AppAssets.appLogo,
                      width: AppSizes.authLogo,
                      height: AppSizes.authLogo,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                const FieldLabel(
                  AppStrings.emailLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) =>
                      Validators.email(controller.emailController.text),
                  builder: (state) {
                    return AppTextField(
                      controller: controller.emailController,
                      hintText: AppStrings.enterEmail,
                      leadingIcon: Icons.person_outline,
                      errorText: state.errorText,
                      onChanged: (val) {
                        state.didChange(val);
                        if (state.hasError) state.validate();
                      },
                    );
                  },
                ),
                SizedBox(height: AppSpacing.md),
                const FieldLabel(
                  AppStrings.passwordLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) =>
                      Validators.password(controller.passwordController.text),
                  builder: (state) {
                    return AppPasswordField(
                      controller: controller.passwordController,
                      hintText: AppStrings.passwordLabel,
                      errorText: state.errorText,
                    );
                  },
                ),
                SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextLinkButton(
                    text: AppStrings.forgotPassword,
                    isSecondary: true,
                    onPressed: () => Get.toNamed(Routes.forgotPassword),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Obx(
                  () => PrimaryButton(
                    text: AppStrings.login,
                    onPressed: controller.submit,
                    expand: true,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                const AuthDivider(),
                SizedBox(height: AppSpacing.lg),
                // Phase 6/F.2: beyond the documented one-line onPressed
                // rewire, this button is now Obx-wrapped with a real
                // isLoading binding (was hardcoded `false`) so the button's
                // own spinner (see GoogleAuthButton) actually reflects an
                // in-flight Google sign-in instead of staying tappable.
                Obx(() => Center(
                  child: GoogleAuthButton(
                    isLoading: controller.isLoading.value,
                    onPressed: controller.signInWithGoogle,
                  ),
                )),
                SizedBox(height: AppSpacing.lg),
                AuthFooterPrompt(
                  promptText: "Don't have an account?",
                  actionText: "Sign up",
                  onPressed: () => Get.toNamed(Routes.signup),
                ),
                SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
