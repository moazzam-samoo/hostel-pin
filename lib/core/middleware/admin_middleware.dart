import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../core/enums/user_role.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/session_service.dart';

/// Guards all /admin/* routes (except /admin/login itself).
/// Mirrors AuthMiddleware's exact shape (TASK-Phase-9 Block A.5):
/// checks that the signed-in user's role is [UserRole.admin];
/// redirects to the admin login screen otherwise.
class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final sessionService = Get.find<SessionService>();
    if (sessionService.currentUser.value?.role != UserRole.admin) {
      return const RouteSettings(name: Routes.adminLogin);
    }
    return null;
  }
}
