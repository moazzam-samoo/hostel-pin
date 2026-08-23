import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/confirm_dialog.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../shell/owner_shell_controller.dart';

class OwnerProfileController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  Rx<UserModel?> get currentUser => _sessionService.currentUser;

  // App Preferences — reads straight from the current user's prefs so it
  // stays in sync via the `currentUser` Rx dependency registered wherever
  // this getter is read inside an Obx (no separate .obs needed here).
  bool get notificationsEnabled =>
      currentUser.value?.prefs.notifications ?? true;

  void toggleNotifications() async {
    final user = currentUser.value;
    if (user != null) {
      final newPrefs =
          user.prefs.copyWith(notifications: !user.prefs.notifications);
      final updatedUser = user.copyWith(prefs: newPrefs);
      // Optimistic local update
      currentUser.value = updatedUser;
      
      // Persist to Firestore
      await _userRepo.updateUserDoc(updatedUser);
    }
  }

  void navigateToVerificationCenter() {
    Get.toNamed(Routes.ownerVerification);
  }

  Future<void> onEditAvatar() async {
    final user = currentUser.value;
    if (user == null) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    try {
      AppSnackbar.showGlobal(message: 'Uploading avatar...', type: SnackbarType.info);
      final result = await _storageService.uploadImage(File(xFile.path), 'avatars');
      
      final updatedUser = user.copyWith(photoUrl: result.url);
      await _userRepo.updateUserDoc(updatedUser);
      
      AppSnackbar.showGlobal(message: 'Avatar updated!', type: SnackbarType.success);
    } catch (e) {
      AppSnackbar.showGlobal(message: 'Failed to upload avatar', type: SnackbarType.error);
    }
  }

  void navigateToAccountSettings() {
    Get.toNamed(Routes.ownerAccountSettings);
  }

  void navigateToMyHostels() {
    // Switch to the Listings tab (index 1) inside the owner shell, same
    // tab-switch pattern as Dashboard's "View listing" action.
    if (Get.isRegistered<OwnerShellController>()) {
      Get.find<OwnerShellController>().onTabSelected(1);
    }
  }

  void logout() {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.logoutConfirmTitle,
        message: AppStrings.logoutConfirmMessage,
        confirmText: AppStrings.logoutTitle,
        isDestructive: true,
        onConfirm: () async {
          Get.back(); // close dialog
          await _authRepo.signOut();
          Get.offAllNamed(Routes.login);
        },
        onCancel: () => Get.back(),
      ),
    );
  }
}
