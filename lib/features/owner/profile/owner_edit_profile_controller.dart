import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class OwnerEditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final isLoading = false.obs;

  final MockDataService _dataService = Get.find<MockDataService>();

  @override
  void onInit() {
    super.onInit();
    final user = _dataService.currentUser.value;
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
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      final user = _dataService.currentUser.value;
      if (user != null) {
        final updated = user.copyWith(displayName: nameController.text.trim());
        _dataService.currentUser.value = updated;
        // In real app, persist to Firestore
      }

      isLoading.value = false;
      Get.back();
      AppSnackbar.showGlobal(message: AppStrings.editProfileSaved, type: SnackbarType.success);
    }
  }
}
