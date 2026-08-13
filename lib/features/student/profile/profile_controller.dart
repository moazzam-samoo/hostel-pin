import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/confirm_dialog.dart';
import '../shell/student_shell_controller.dart';

class ProfileController extends GetxController {
  final _dataService = Get.find<MockDataService>();

  UserModel? get user => _dataService.currentUser.value;

  int get savedCount => _dataService.savedHostelIds.length;

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
        onConfirm: () {
          Get.back();
          Get.offAllNamed(Routes.login);
        },
        onCancel: () => Get.back(),
      ),
    );
  }
}
