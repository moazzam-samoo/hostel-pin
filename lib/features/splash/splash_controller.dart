import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed(Routes.welcome);
  }
}
