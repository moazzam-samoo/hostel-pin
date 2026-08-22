import 'package:get/get.dart';
import 'auth_controller.dart';
import 'controller/login_controller.dart';
import 'controller/signup_controller.dart';
import 'controller/forgot_password_controller.dart';
import 'controller/change_password_controller.dart';
import 'controller/otp_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Role Selection now runs before Login/Signup and registers AuthController
    // first so the chosen role survives into the auth screens; guard here so
    // re-entering this binding (e.g. Login <-> Signup) doesn't wipe it out.
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<SignupController>(() => SignupController());
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
    Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
