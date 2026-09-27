import 'package:get/get.dart';
import 'admin_shell_controller.dart';
import '../dashboard/admin_dashboard_controller.dart';
import '../users/admin_users_controller.dart';
import '../owners/admin_owners_controller.dart';
import '../hostels/admin_hostels_controller.dart';
import '../verifications/admin_verifications_controller.dart';
import '../notifications/admin_notifications_controller.dart';
import '../settings/admin_settings_controller.dart';
// Note: We'll also lazyPut controllers for all 7 tabs here when they are built

class AdminShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminShellController>(() => AdminShellController());
    
    // Register tab controllers here
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    Get.lazyPut<AdminUsersController>(() => AdminUsersController());
    Get.lazyPut<AdminOwnersController>(() => AdminOwnersController());
    Get.lazyPut<AdminHostelsController>(() => AdminHostelsController());
    Get.lazyPut<AdminVerificationsController>(() => AdminVerificationsController());
    Get.lazyPut<AdminNotificationsController>(() => AdminNotificationsController());
    // Get.lazyPut<AdminReportsController>(() => AdminReportsController());
    Get.lazyPut<AdminSettingsController>(() => AdminSettingsController());
  }
}
