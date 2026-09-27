import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/session_service.dart';

class AdminShellController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  // Track the currently selected tab index in the admin panel. Order must
  // stay in lockstep with AdminShellView._tabs / AdminSidebar's 7 items:
  // Dashboard(0)/Users(1)/Owners(2)/Hostels(3)/Notification(4)/
  // Verification Queue(5)/Settings(6).
  final RxInt currentIndex = 0.obs;

  // Maps a direct /admin/* URL (bookmarked or refreshed — this is a real
  // web app, so browser URL navigation matters, unlike the mobile shells'
  // equivalent unused sub-routes) to its tab index, so landing on e.g.
  // /admin/users via a fresh page load shows the real Users tab instead of
  // always defaulting to Dashboard.
  static const Map<String, int> _routeTabIndex = {
    Routes.adminDashboard: 0,
    Routes.adminUsers: 1,
    Routes.adminOwners: 2,
    Routes.adminHostels: 3,
    Routes.adminNotifications: 4,
    Routes.adminVerification: 5,
    Routes.adminReview: 5,
    Routes.adminSettings: 6,
  };

  UserModel? get currentAdmin => _sessionService.currentUser.value;

  @override
  void onInit() {
    super.onInit();
    final initialIndex = _routeTabIndex[Get.currentRoute];
    if (initialIndex != null) {
      currentIndex.value = initialIndex;
    }
  }

  // Handle sidebar/top-bar navigation
  void changeTab(int index) {
    currentIndex.value = index;
  }

  // Admin sign out
  Future<void> signOut() async {
    await _authRepo.signOut();
    // AdminMiddleware bounces the now-signed-out session back to
    // /admin/login on the next guarded navigation; SessionService's
    // authStateChanges listener clears currentUser reactively.
    Get.offAllNamed(Routes.adminLogin);
  }
}
