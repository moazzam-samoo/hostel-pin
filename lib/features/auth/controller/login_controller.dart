import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../auth_controller.dart';
import '../../../core/errors/failure.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();

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

    isLoading.value = true;
    try {
      final credential = await _authRepo.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (credential.user != null) {
        final userDoc = await _userRepo.getUserDoc(credential.user!.uid);
        if (userDoc != null) {
          if (userDoc.role == UserRole.admin) {
            Get.offAllNamed(Routes.adminShell);
          } else {
            Get.offAllNamed(userDoc.role == UserRole.student
                ? Routes.studentShell
                : Routes.ownerShell);
          }
        } else {
          // Fallback if no user doc (shouldn't happen for email login)
          Get.offAllNamed(Routes.roleSelection);
        }
      }
    } on Failure catch (f) {
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      // Block F: new identity -> just-picked role; returning identity ->
      // stored role wins. Resolved centrally in AuthRepository so Login's
      // and Signup's Google buttons share one implementation.
      final result = await _authRepo.signInWithGoogleAndResolveRole(
        fallbackRole: authController.selectedRole.value ?? UserRole.student,
      );
      if (result != null) {
        if (result.role == UserRole.admin) {
          Get.offAllNamed(Routes.adminShell);
        } else {
          Get.offAllNamed(result.role == UserRole.student
              ? Routes.studentShell
              : Routes.ownerShell);
        }
      }
    } on Failure catch (f) {
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
