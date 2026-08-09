import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(text: '+92');
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final acceptedTerms = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (!acceptedTerms.value) {
      AppSnackbar.showGlobal(message: 'Please accept the Terms of Service to continue', type: SnackbarType.error);
      return;
    }

    // Trigger failure path for testing error UI
    if (emailController.text == 'error@test.com') {
      AppSnackbar.showGlobal(message: 'Email already in use (Mock Error)', type: SnackbarType.error);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;

    // Route to role selection post-auth
    Get.offAllNamed(Routes.roleSelection);
  }
}
