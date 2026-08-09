import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../auth_controller.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    // Trigger failure path for testing error UI
    if (emailController.text == 'error@test.com') {
      Get.snackbar('Error', 'Invalid credentials (Mock Error)');
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;

    // Route to role selection post-auth
    Get.offAllNamed(Routes.roleSelection);
  }
}
