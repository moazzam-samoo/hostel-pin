import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/user_role.dart';
import '../../core/errors/failure.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/session_service.dart';
import '../../shared/widgets/feedback/app_snackbar.dart';
import '../../shared/widgets/feedback/confirm_dialog.dart';
import '../auth/widgets/reauth_dialog.dart';

/// Account Settings (student + owner share it): legal links and in-app
/// account deletion, which Google Play requires for any app that lets users
/// create an account.
class AccountController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final AccountRepository _accountRepo = Get.find<AccountRepository>();
  final SessionService _session = Get.find<SessionService>();

  final isDeleting = false.obs;

  void openPrivacyPolicy() => Get.toNamed(Routes.privacyPolicy);
  void openTerms() => Get.toNamed(Routes.termsOfService);

  /// Step 1: confirm intent.
  void requestDeleteAccount() {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.deleteAccountConfirmTitle,
        message: AppStrings.deleteAccountConfirmMessage,
        confirmText: AppStrings.deleteAccountConfirmButton,
        isDestructive: true,
        onConfirm: () {
          Get.back();
          _reauthenticateThenDelete();
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  /// Step 2: prove it is the account owner (Firebase requires a recent
  /// sign-in to delete an account), by password or by Google again.
  Future<void> _reauthenticateThenDelete() async {
    if (_authRepo.usesPasswordProvider) {
      Get.dialog(
        ReauthDialog(
          onConfirm: (password) async {
            try {
              await _authRepo.reauthenticateWithCredential(password);
            } on Failure catch (f) {
              AppSnackbar.showGlobal(
                  message: f.message, type: SnackbarType.error);
              return;
            }
            Get.back(); // close the password dialog
            await _deleteEverything();
          },
        ),
      );
      return;
    }

    isDeleting.value = true;
    try {
      final confirmed = await _authRepo.reauthenticateWithGoogle();
      if (!confirmed) {
        isDeleting.value = false;
        return;
      }
    } on Failure catch (f) {
      isDeleting.value = false;
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
      return;
    }
    await _deleteEverything();
  }

  String _deletionMessage(Object e) {
    if (e is Failure) {
      if (e.message == AppStrings.errorRequiresRecentLogin) {
        return AppStrings.deleteAccountRecentLogin;
      }
      final cause = e.error;
      if (cause is FirebaseException && cause.code == 'permission-denied') {
        return AppStrings.deleteAccountPermissionDenied;
      }
    }
    return AppStrings.deleteAccountFailed;
  }

  /// Step 3: delete Firestore data, then the Auth user, then leave.
  Future<void> _deleteEverything() async {
    final user = _session.currentUser.value;
    if (user == null) {
      AppSnackbar.showGlobal(
          message: AppStrings.deleteAccountFailed, type: SnackbarType.error);
      return;
    }

    isDeleting.value = true;
    try {
      await _accountRepo.deleteUserData(
        user.uid,
        isOwner: user.role == UserRole.owner,
      );
      await _authRepo.deleteAccount();
      Get.offAllNamed(Routes.login);
      AppSnackbar.showGlobal(
          message: AppStrings.deleteAccountSuccess, type: SnackbarType.success);
    } catch (e) {
      // Log the REAL cause (the user only sees a short message). A rejected
      // delete usually means the deployed Firestore rules are older than the
      // app and do not yet allow a user to delete their own profile.
      Logger.e('Account deletion failed: $e');
      AppSnackbar.showGlobal(
        message: _deletionMessage(e),
        type: SnackbarType.error,
      );
    } finally {
      isDeleting.value = false;
    }
  }
}
