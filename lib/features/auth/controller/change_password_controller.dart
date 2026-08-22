import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/errors/failure.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/reauth_dialog.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });
    super.onClose();
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authRepo.updatePassword(newPasswordController.text);
      Get.offNamed(Routes.passwordSuccess);
    } on Failure catch (f) {
      if (f.message == AppStrings.errorRequiresRecentLogin) {
        _showReauthDialog();
      } else {
        AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showReauthDialog() {
    Get.dialog(
      ReauthDialog(
        onConfirm: (currentPassword) async {
          isLoading.value = true;
          try {
            await _authRepo.reauthenticateWithCredential(currentPassword);
            // Retry the password change now that the session is fresh.
            await _authRepo.updatePassword(newPasswordController.text);
            Get.back(); // close the reauth dialog
            Get.offNamed(Routes.passwordSuccess);
          } on Failure catch (f) {
            AppSnackbar.showGlobal(
                message: f.message, type: SnackbarType.error);
          } finally {
            isLoading.value = false;
          }
        },
      ),
    );
  }
}
