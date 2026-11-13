import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../auth_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/failure.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// Email/password login in flight.
  final isLoading = false.obs;

  /// Google sign-in in flight (separate, so only the tapped button spins).
  final isGoogleLoading = false.obs;

  /// The account type chosen on Role Selection, switchable here. Defaults to
  /// Student for display if somehow unset.
  UserRole get selectedRole => authController.selectedRole.value ?? UserRole.student;

  void setRole(UserRole role) => authController.selectedRole.value = role;

  /// An existing account keeps ONE role. If the user picked the other type,
  /// do not silently log them into the wrong app: sign out and explain.
  /// Returns true when a mismatch was found (and handled).
  Future<bool> _rejectRoleMismatch(UserRole storedRole) async {
    final picked = authController.selectedRole.value;
    if (picked == null || storedRole == UserRole.admin || picked == storedRole) {
      return false;
    }
    await _authRepo.signOut();
    AppSnackbar.showGlobal(
      message: AppStrings.loginRoleMismatch(_roleLabel(storedRole)),
      type: SnackbarType.error,
    );
    return true;
  }

  String _roleLabel(UserRole role) => role == UserRole.owner
      ? AppStrings.ownerSectionTitle
      : AppStrings.studentSectionTitle;

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

    if (isLoading.value || isGoogleLoading.value) return;
    isLoading.value = true;
    try {
      final credential = await _authRepo.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (credential.user != null) {
        var userDoc = await _userRepo.getUserDoc(credential.user!.uid);
        // Self-heal an account whose profile document was never written
        // (e.g. signup crashed between creating the Auth user and the
        // Firestore doc). Role Selection runs before login, so the role the
        // user just picked is the right one to create it with.
        if (userDoc == null) {
          final fbUser = credential.user!;
          // Only for a freshly created account (the interrupted-signup case).
          // An older account with no profile was removed by an admin, and
          // must not be silently resurrected by logging in again.
          final created = fbUser.metadata.creationTime;
          final isFresh = created != null &&
              DateTime.now().difference(created) < const Duration(hours: 24);
          if (!isFresh) {
            await _authRepo.signOut();
            AppSnackbar.showGlobal(
              message: AppStrings.errorAccountRemoved,
              type: SnackbarType.error,
            );
            return;
          }
          userDoc = UserModel(
            uid: fbUser.uid,
            displayName: fbUser.displayName ??
                (fbUser.email ?? '').split('@').first,
            email: fbUser.email ?? '',
            photoUrl: fbUser.photoURL,
            role: authController.selectedRole.value ?? UserRole.student,
          );
          await _userRepo.createUserDoc(userDoc);
        }
        if (userDoc.status == 'blocked') {
          await _authRepo.signOut();
          AppSnackbar.showGlobal(
            message: AppStrings.errorAccountBlocked,
            type: SnackbarType.error,
          );
          return;
        }
        if (await _rejectRoleMismatch(userDoc.role)) return;
        if (userDoc.role == UserRole.admin) {
          Get.offAllNamed(Routes.adminShell);
        } else {
          Get.offAllNamed(userDoc.role == UserRole.student
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

  Future<void> signInWithGoogle() async {
    if (isLoading.value || isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    try {
      // Block F: new identity -> just-picked role; returning identity ->
      // stored role wins. Resolved centrally in AuthRepository so Login's
      // and Signup's Google buttons share one implementation.
      final result = await _authRepo.signInWithGoogleAndResolveRole(
        fallbackRole: authController.selectedRole.value ?? UserRole.student,
      );
      if (result != null) {
        if (!result.isNewUser && await _rejectRoleMismatch(result.role)) return;
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
      isGoogleLoading.value = false;
    }
  }
}
