import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/inputs/app_password_field.dart';
import '../../../shared/widgets/inputs/field_label.dart';

/// D.4's reauth prompt: shown when a sensitive Firebase Auth operation (e.g.
/// `updatePassword`) throws `requires-recent-login`. `ChangePasswordView`
/// has no "current password" field, so this is a **separate** dialog widget
/// rather than an edit to that view — keeps the "zero required view
/// changes" goal literally true while still collecting the current password
/// `reauthenticateWithCredential` needs.
class ReauthDialog extends StatefulWidget {
  final Future<void> Function(String currentPassword) onConfirm;

  const ReauthDialog({super.key, required this.onConfirm});

  @override
  State<ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<ReauthDialog> {
  final _passwordController = TextEditingController();
  final _isSubmitting = false.obs;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorText = AppStrings.errorPasswordRequired);
      return;
    }
    setState(() => _errorText = null);
    _isSubmitting.value = true;
    try {
      await widget.onConfirm(_passwordController.text);
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.reauthTitle,
              style: AppTextStyles.sectionHeader,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              AppStrings.reauthMessage,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            const FieldLabel(
              AppStrings.passwordLabel,
              style: FieldLabelStyle.auth,
            ),
            SizedBox(height: AppSpacing.xs),
            AppPasswordField(
              controller: _passwordController,
              hintText: AppStrings.passwordLabel,
              errorText: _errorText,
            ),
            SizedBox(height: AppSpacing.xl),
            Obx(
              () => PrimaryButton(
                text: AppStrings.reauthConfirmButton,
                onPressed: _submit,
                isLoading: _isSubmitting.value,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              text: AppStrings.cancelButton,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
