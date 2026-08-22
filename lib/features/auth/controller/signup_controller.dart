import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../auth_controller.dart';
import '../../../core/errors/failure.dart';

class SignupController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    });
    super.onClose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (!acceptedTerms.value) {
      AppSnackbar.showGlobal(
          message: 'Please accept the Terms of Service to continue',
          type: SnackbarType.error);
      return;
    }

    isLoading.value = true;
    try {
      final credential = await _authRepo.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (credential.user != null) {
        final role = authController.selectedRole.value ?? UserRole.student;
        
        final newUserDoc = UserModel(
          uid: credential.user!.uid,
          displayName: nameController.text.trim(),
          email: credential.user!.email ?? emailController.text.trim(),
          phone: phoneController.text.trim(),
          role: role,
        );
        await _userRepo.createUserDoc(newUserDoc);

        Get.offAllNamed(
            role == UserRole.student ? Routes.studentShell : Routes.ownerShell);
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
        Get.offAllNamed(result.role == UserRole.student
            ? Routes.studentShell
            : Routes.ownerShell);
      }
    } on Failure catch (f) {
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
