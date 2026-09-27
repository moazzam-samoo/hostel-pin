import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../core/errors/failure.dart';
import '../../../core/constants/app_strings.dart';

class AdminLoginController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();
  final AuthService _authService = Get.find<AuthService>();

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

    isLoading.value = true;
    try {
      final credential = await _authRepo.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (credential.user != null) {
        final userDoc = await _userRepo.getUserDoc(credential.user!.uid);
        if (userDoc != null && userDoc.role == UserRole.admin) {
          // Real admin — navigate to the admin shell
          Get.offAllNamed(Routes.adminShell);
        } else {
          // Not an admin account — sign back out immediately and show error
          await _authService.signOut();
          AppSnackbar.showGlobal(
            message: AppStrings.adminAccessDenied,
            type: SnackbarType.error,
          );
        }
      }
    } on Failure catch (f) {
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
