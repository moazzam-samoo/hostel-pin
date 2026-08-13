import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class OtpController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpController.dispose();
    });
    super.onClose();
  }

  Future<void> verifyOtp() async {
    if (otpController.text != '1234') {
      AppSnackbar.showGlobal(message: 'Invalid OTP. Try again.', type: SnackbarType.error);
      return;
    }
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;
    Get.toNamed(Routes.changePassword);
  }
}
