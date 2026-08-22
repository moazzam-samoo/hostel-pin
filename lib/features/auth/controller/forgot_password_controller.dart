import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/errors/failure.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailController.dispose();
    });
    super.onClose();
  }

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authRepo.sendPasswordResetEmail(emailController.text.trim());
      Get.toNamed(Routes.checkEmail, arguments: emailController.text);
    } on Failure catch (f) {
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
