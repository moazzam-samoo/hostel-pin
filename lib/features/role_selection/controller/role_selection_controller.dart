import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/auth_controller.dart';

class RoleSelectionController extends GetxController {
  // AuthController is guaranteed to be available here — RoleSelectionBinding
  // registers it (Role Selection now runs before Login/Signup, per the
  // decision to know the role before the DB account is created/authenticated).
  Future<void> selectRole(UserRole role) async {
    Get.find<AuthController>().selectedRole.value = role;
    // Login (and, via its footer link, Signup) reads selectedRole once the
    // user actually authenticates, then sets the mock current user and
    // routes to the matching shell. Pushed (not offAllNamed) so the back
    // button returns here to change roles.
    Get.toNamed(Routes.login);
  }
}
