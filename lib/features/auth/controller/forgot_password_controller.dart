import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;
    // Pass email as argument to checkEmail view
    Get.toNamed(Routes.checkEmail, arguments: emailController.text);
  }
}
