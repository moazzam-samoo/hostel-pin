import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class PasswordSuccessView extends StatelessWidget {
  const PasswordSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        variant: AppTopBarVariant.backOnly,
      ),
      applyGutter: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.passwordSuccess,
              width: 150,
              height: 150,
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.passwordSuccessTitle,
              style: AppTextStyles.successTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              AppStrings.passwordSuccessBody,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.passwordSuccessFooter,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: AppStrings.okButton,
              // Only reachable today via Profile -> Change Password
              // (D1 repurposed this flow away from password reset), which
              // pushes on top of Profile then replaces itself with this
              // screen — so Profile is still directly below on the stack.
              // A single pop returns there; it never routes to Login.
              onPressed: () => Get.back(),
              expand: true,
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
