import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class EditProfileController extends GetxController {
  final _dataService = Get.find<MockDataService>();

  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: _dataService.currentUser.value?.displayName ?? '');
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;

    final current = _dataService.currentUser.value;
    if (current != null) {
      _dataService.currentUser.value = current.copyWith(displayName: nameController.text.trim());
    }

    AppSnackbar.showGlobal(message: AppStrings.editProfileSaved, type: SnackbarType.success);
    Get.back();
  }
}
