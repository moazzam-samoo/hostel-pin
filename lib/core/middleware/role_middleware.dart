import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/session_service.dart';
import '../enums/user_role.dart';

class RoleMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    final sessionService = Get.find<SessionService>();
    final user = sessionService.currentUser.value;

    if (user == null) {
      // AuthMiddleware (which runs alongside RoleMiddleware on every
      // protected GetPage) already sends genuinely signed-out users to
      // Login, so reaching this branch with a real Firebase user means
      // they're signed in but their users/{uid} doc is missing/unreadable —
      // a corrupt/incomplete account (C.3/C.4's "recovery path" case), not
      // the normal Splash-is-still-resolving transient. Send them to Role
      // Selection to (re-)start the pre-auth flow properly rather than
      // silently letting them through to a role-gated screen with no role.
      if (authService.currentUser != null) {
        return const RouteSettings(name: Routes.roleSelection);
      }
      return null;
    }

    // Admin users accessing student/owner shells should be redirected to admin shell.
    if (user.role == UserRole.admin &&
        (route == Routes.studentShell || route == Routes.ownerShell)) {
      return const RouteSettings(name: Routes.adminShell);
    }

    if (route == Routes.studentShell && user.role == UserRole.owner) {
      return const RouteSettings(name: Routes.ownerShell);
    }

    if (route == Routes.ownerShell && user.role == UserRole.student) {
      return const RouteSettings(name: Routes.studentShell);
    }

    return null;
  }
}
