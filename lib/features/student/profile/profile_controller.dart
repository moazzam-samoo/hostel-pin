import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/session_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/confirm_dialog.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../shell/student_shell_controller.dart';

class ProfileController extends GetxController {
  final _sessionService = Get.find<SessionService>();
  final _savedRepo = Get.find<SavedRepository>();
  final _authRepo = Get.find<AuthRepository>();
  final _userRepo = Get.find<UserRepository>();
  final _storageService = Get.find<StorageService>();

  UserModel? get user => _sessionService.currentUser.value;

  final RxInt savedCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final uid = user?.uid;
    if (uid != null) {
      _savedRepo.streamSaved(uid).listen((saved) {
        savedCount.value = saved.length;
      });
    }
  }

  // Mock preferences. Dark Mode has no real theme yet (I17) — the toggle is
  // rendered disabled with a "Coming soon" label rather than silently doing
  // nothing when flipped.
  final isDarkMode = false.obs;
  final notificationsEnabled = true.obs;

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void onEditProfile() {
    Get.toNamed(Routes.studentEditProfile);
  }

  Future<void> onEditAvatar() async {
    final uid = user?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    try {
      AppSnackbar.showGlobal(message: 'Uploading avatar...', type: SnackbarType.info);
      final result = await _storageService.uploadImage(File(xFile.path), 'avatars');
      
      final updatedUser = user!.copyWith(photoUrl: result.url);
      await _userRepo.updateUserDoc(updatedUser);
      
      AppSnackbar.showGlobal(message: 'Avatar updated!', type: SnackbarType.success);
    } catch (e) {
      AppSnackbar.showGlobal(message: 'Failed to upload avatar', type: SnackbarType.error);
    }
  }

  void onSavedHostels() {
    // Jumps to the Saved tab inside the shell rather than a new route.
    Get.find<StudentShellController>().onTabSelected(2);
  }

  void onChangePassword() {
    Get.toNamed(Routes.changePassword);
  }

  void onAccountSettings() {
    Get.toNamed(Routes.studentSettings);
  }

  void onPrivacySettings() {
    Get.toNamed(Routes.studentPrivacy);
  }

  void onLogout() {
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
