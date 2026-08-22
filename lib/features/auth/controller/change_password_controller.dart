import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class ChangePasswordController extends GetxController {
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

    if (newPasswordController.text.startsWith('Error')) {
      AppSnackbar.showGlobal(
          message: 'Could not update password. Try again.',
          type: SnackbarType.error);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;
    Get.offNamed(Routes.passwordSuccess);
  }
}
