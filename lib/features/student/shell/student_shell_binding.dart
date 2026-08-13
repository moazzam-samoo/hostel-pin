import 'package:get/get.dart';
import 'student_shell_controller.dart';
import '../home/home_controller.dart';
import '../map/map_controller.dart';
import '../saved/saved_controller.dart';
import '../profile/profile_controller.dart';

class StudentShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentShellController>(() => StudentShellController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MapController>(() => MapController());
    Get.lazyPut<SavedController>(() => SavedController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
