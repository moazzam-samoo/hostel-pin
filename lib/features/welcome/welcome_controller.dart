import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';

class WelcomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _markWelcomeSeen();
  }

  Future<void> _markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);
  }

  void onContinue() {
    Get.toNamed(Routes.login);
  }
}
