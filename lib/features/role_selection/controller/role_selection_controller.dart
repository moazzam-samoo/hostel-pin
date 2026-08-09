import 'package:get/get.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';

class RoleSelectionController extends GetxController {
  final isLoading = false.obs;
  final selectedRole = Rx<UserRole?>(null);

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  Future<void> confirmRole() async {
    if (selectedRole.value == null) return;
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isLoading.value = false;
    
    if (selectedRole.value == UserRole.student) {
      Get.offAllNamed(Routes.studentHome);
    } else {
      Get.offAllNamed(Routes.ownerDashboard);
    }
  }
}
