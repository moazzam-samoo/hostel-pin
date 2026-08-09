import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

class OtpController extends GetxController {
  final isLoading = false.obs;

  Future<void> verifyOtp() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;
    Get.toNamed(Routes.changePassword);
  }
}
