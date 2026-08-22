import 'package:get/get.dart';
import 'controller/role_selection_controller.dart';
import '../auth/auth_controller.dart';

class RoleSelectionBinding extends Bindings {
  @override
  void dependencies() {
    // Role Selection is now reached before Login/Signup, so it's the first
    // screen that needs AuthController — register it here (guarded, since
    // AuthBinding registers the same guarded instance later on Login/Signup).
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    Get.lazyPut<RoleSelectionController>(() => RoleSelectionController());
  }
}
