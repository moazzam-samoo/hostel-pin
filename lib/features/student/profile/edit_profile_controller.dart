import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/session_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/errors/failure.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class EditProfileController extends GetxController {
  final _sessionService = Get.find<SessionService>();
  final _userRepo = Get.find<UserRepository>();

  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(
        text: _sessionService.currentUser.value?.displayName ?? '');
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final current = _sessionService.currentUser.value;
    if (current == null) return;

    isLoading.value = true;
    try {
      final updated =
          current.copyWith(displayName: nameController.text.trim());
      await _userRepo.updateUserDoc(updated);
      // SessionService's live users/{uid} stream picks up the change; no
      // local mutation needed here.
      AppSnackbar.showGlobal(
          message: AppStrings.editProfileSaved, type: SnackbarType.success);
      Get.back();
    } on Failure catch (f) {
      AppSnackbar.showGlobal(message: f.message, type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
