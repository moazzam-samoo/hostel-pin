import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (authService.currentUser == null) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}
