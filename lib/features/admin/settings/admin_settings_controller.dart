import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/app_config_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/app_config_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/session_service.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';

/// Phase 9 Block H — Settings. Two independent sections:
///  1. The signed-in admin's own profile (H.1) — real, functional, backed
///     by SessionService/UserRepository like OwnerEditProfileController.
///  2. Feature-flag toggles (H.2) — the 4 booleans Appendix C names,
///     written to `config/appSettings` via AppConfigRepository. This is the
///     doc `firestore.rules`' `config/{docId}` rule already covers
///     (`allow read: if true; allow write: if isAdmin();`) — the previous
///     `system/admin_settings` doc this controller used to read/write had
///     no rule at all and was silently permission-denied in production.
class AdminSettingsController extends GetxController {
  final AppConfigRepository _configRepo = Get.find<AppConfigRepository>();
  final SessionService _sessionService = Get.find<SessionService>();
  final UserRepository _userRepo = Get.find<UserRepository>();

  final Rx<AppConfigModel> config = const AppConfigModel().obs;
  final RxBool isLoading = true.obs;
  final RxBool isSavingProfile = false.obs;

  UserModel? get currentAdmin => _sessionService.currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _configRepo.streamConfig().listen((value) {
      config.value = value;
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });
  }

  Future<void> toggleAllowNewSignups(bool val) => _save(config.value.copyWith(allowNewSignups: val));
  Future<void> toggleWhatsappIntegration(bool val) => _save(config.value.copyWith(whatsappIntegration: val));
  Future<void> toggleAutoApproveOwners(bool val) => _save(config.value.copyWith(autoApproveOwners: val));
  Future<void> toggleMaintenanceMode(bool val) => _save(config.value.copyWith(maintenanceMode: val));

  Future<void> _save(AppConfigModel updated) async {
    config.value = updated;
    try {
      await _configRepo.updateConfig(updated);
      AppSnackbar.showGlobal(message: AppStrings.adminSettingsSaved, type: SnackbarType.success);
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminSettingsSaveError, type: SnackbarType.error);
    }
  }

  /// H.1 — reuses OwnerEditProfileController's exact pattern: read/write
  /// through SessionService.currentUser/UserRepository, a real signed-in
  /// Firebase user with a real users/{uid} doc (true from the moment Block
  /// A's real admin auth lands).
  Future<void> saveDisplayName(String newName) async {
    final user = currentAdmin;
    if (user == null || newName.trim().isEmpty) return;

    isSavingProfile.value = true;
    try {
      final updated = user.copyWith(displayName: newName.trim());
      await _userRepo.updateUserDoc(updated);
      Get.back();
      AppSnackbar.showGlobal(message: AppStrings.adminProfileUpdated, type: SnackbarType.success);
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminGenericUpdateError, type: SnackbarType.error);
    } finally {
      isSavingProfile.value = false;
    }
  }
}
