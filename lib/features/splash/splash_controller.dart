import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';

import '../../data/services/auth_service.dart';
import '../../data/services/session_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/enums/user_role.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _resolve();
  }

  Future<void> _resolve() async {
    // Keep a minimum splash duration for UX, but gate the *destination* on
    // real SessionService/auth state (C.3), not on the timer alone.
    final minDuration = Future.delayed(const Duration(seconds: 2));

    final authService = Get.find<AuthService>();
    final firebaseUser = authService.currentUser;

    if (firebaseUser == null) {
      await minDuration;
      Get.offAllNamed(Routes.welcome);
      return;
    }

    // Signed in: resolve the users/{uid} role. SessionService's live stream
    // may already have it (warm relaunch); otherwise fall back to a single
    // bounded read so a genuinely missing/unreadable doc routes to Role
    // Selection as the C.3 recovery path instead of hanging here forever —
    // the previous implementation only listened via `ever()`, which never
    // fires when the stream's resolved value stays null.
    final sessionService = Get.find<SessionService>();
    UserRole? role = sessionService.currentUser.value?.role;

    if (role == null) {
      try {
        final doc = await Get.find<UserRepository>()
            .getUserDoc(firebaseUser.uid)
            .timeout(const Duration(seconds: 8));
        role = doc?.role;
      } catch (_) {
        role = null;
      }
    }

    await minDuration;

    if (role == null) {
      Get.offAllNamed(Routes.roleSelection);
    } else if (role == UserRole.admin) {
      Get.offAllNamed(Routes.adminShell);
    } else if (role == UserRole.owner) {
      Get.offAllNamed(Routes.ownerShell);
    } else {
      Get.offAllNamed(Routes.studentShell);
    }
  }
}
