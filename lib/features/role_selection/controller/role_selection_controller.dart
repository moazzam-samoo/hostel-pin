import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/auth_controller.dart';

class RoleSelectionController extends GetxController {
  // AuthController is guaranteed to be available here as it's registered
  // by AuthBinding during Login/Signup before reaching Role Selection.
  // Note: Deep linking directly to Role Selection would require checking if AuthController exists.
  Future<void> selectRole(UserRole role) async {
    Get.find<AuthController>().selectedRole.value = role;
    if (role == UserRole.student) {
      Get.offAllNamed(Routes.studentShell);
    } else {
      Get.offAllNamed(Routes.ownerShell);
    }
  }
}
