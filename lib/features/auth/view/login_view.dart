import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
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

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthHeroSheet(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.xl),
                Text(
                  AppStrings.welcomeBack,
                  style: AppTextStyles.authTitle.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Center(
                  child: ConfettiDots(
                    child: Image.asset(
                      AppAssets.appLogo,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                const FieldLabel(AppStrings.emailLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) => Validators.email(controller.emailController.text),
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
                const FieldLabel(AppStrings.passwordLabel,
                  style: FieldLabelStyle.auth,
                ),
                SizedBox(height: AppSpacing.xs),
                FormField<String>(
                  validator: (val) => Validators.password(controller.passwordController.text),
                  builder: (state) {
                    return AppPasswordField(
                      controller: controller.passwordController,
                      hintText: AppStrings.passwordLabel,
                      errorText: state.errorText,
                    );
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextLinkButton(text: AppStrings.forgotPassword, isSecondary: true, onPressed: () => Get.toNamed(Routes.forgotPassword),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Obx(
                  () => PrimaryButton(text: AppStrings.login, onPressed: controller.submit,
                    expand: true,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                const AuthDivider(),
                SizedBox(height: AppSpacing.xl),
                Center(child: GoogleAuthButton(isLoading: false, onPressed: () {})),
                SizedBox(height: AppSpacing.xl),
                AuthFooterPrompt(promptText: "Don't have an account?", actionText: "Sign up", onPressed: () => Get.toNamed(Routes.signup),
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
