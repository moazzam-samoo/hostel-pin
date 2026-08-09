import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/cards/auth_form_card.dart';
import '../../../shared/widgets/layout/highlighted_body_text.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/buttons/text_link_button.dart';

class CheckEmailView extends StatelessWidget {
  const CheckEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments as String? ?? 'your email';

    return AppScaffold(
      topBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.checkEmailTitle,
      ),
      applyGutter: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.xl),
            AuthFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mark_email_read, color: AppColors.primary, size: 32),
                  ),
                  SizedBox(height: AppSpacing.md),
                  HighlightedBodyText(
                    textBefore: AppStrings.resetLinkSentPrefix,
                    highlightedText: email,
                    textAfter: AppStrings.resetLinkSentSuffix,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  SecondaryButton(text: AppStrings.resendCode, onPressed: () {},
                    expand: true,
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextLinkButton(text: AppStrings.backToLogin, onPressed: () => Get.offAllNamed(Routes.login),
                    isSecondary: true,
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
