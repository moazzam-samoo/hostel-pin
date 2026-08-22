import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/session_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class OwnerEditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final isLoading = false.obs;

  final SessionService _sessionService = Get.find<SessionService>();
  final UserRepository _userRepo = Get.find<UserRepository>();

  @override
  void onInit() {
    super.onInit();
    final user = _sessionService.currentUser.value;
    if (user != null) {
      nameController.text = user.displayName;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final user = _sessionService.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    try {
      final updated = user.copyWith(displayName: nameController.text.trim());
      await _userRepo.updateUserDoc(updated);
      // SessionService's live users/{uid} stream picks up the change; no
      // local mutation needed here.
      Get.back();
      AppSnackbar.showGlobal(
          message: AppStrings.editProfileSaved, type: SnackbarType.success);
    } on Failure catch (f) {
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
