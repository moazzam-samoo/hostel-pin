import 'package:get/get.dart';
import 'dept_welcome_controller.dart';

class DeptWelcomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeptWelcomeController>(() => DeptWelcomeController());
  }
}
