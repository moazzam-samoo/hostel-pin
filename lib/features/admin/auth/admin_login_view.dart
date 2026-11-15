import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_login_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/inputs/field_label.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class AdminLoginView extends GetView<AdminLoginController> {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            AppAssets.adminLoginBg,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xCC0F172A), Color(0xE61E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.transparent),
          ),

          // Centered Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 48 : 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: isDesktop ? 460 : double.infinity),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(242), // 0.95
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withAlpha(77)), // 0.3
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51), // 0.2
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 20,
                      vertical: isDesktop ? 40 : 28,
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(26), // 0.1
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              AppStrings.adminPortalBadge,
                              style: AppTextStyles.labelMicro.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Logo
                          Image.asset(
                            AppAssets.appLogo,
                            width: isDesktop ? 72 : 60,
                            height: isDesktop ? 72 : 60,
                          ),
                          const SizedBox(height: 24),
                          // Title
                          Text(
                            AppStrings.adminLoginWelcome,
                            style: AppTextStyles.authTitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.adminLoginSubtitle,
                            style: AppTextStyles.screenSubtitle,
                            textAlign: TextAlign.center,
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
                          const SizedBox(height: 8),
                          FormField<String>(
                            validator: (val) => Validators.email(
                                controller.emailController.text),
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
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 24),
                          // Footer note
                          Text(
                            AppStrings.adminLoginHelp,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
