import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../auth_controller.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emailController.dispose();
      passwordController.dispose();
    });
    super.onClose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    // Trigger failure path for testing error UI
    if (emailController.text == 'error@test.com') {
      AppSnackbar.showGlobal(
          message: 'Invalid credentials (Mock Error)',
          type: SnackbarType.error);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;

    // Role was already chosen on Role Selection, before this screen. Fall
    // back to student only if reached directly (e.g. deep link) with no role set.
    final role = authController.selectedRole.value ?? UserRole.student;
    Get.find<MockDataService>().setCurrentUserForRole(role);
    Get.offAllNamed(
        role == UserRole.student ? Routes.studentShell : Routes.ownerShell);
  }
}
