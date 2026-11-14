import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../core/utils/logger.dart';
import '../shell/owner_shell_controller.dart';

class DashboardController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final ActivityRepository _activityRepo = Get.find<ActivityRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final RxList<HostelModel> ownerListings = <HostelModel>[].obs;
  final RxList<ActivityModel> recentActivities = <ActivityModel>[].obs;
  
  StreamSubscription? _listingsSub;
  StreamSubscription? _activitiesSub;

  UserModel? get currentUser => _sessionService.currentUser.value;

  /// Name shown in "Welcome, {name}": the display name, else the part of the
  /// email before the @, else empty.
  String get welcomeName {
    final user = currentUser;
    if (user == null) return '';
    final name = user.displayName.trim();
    if (name.isNotEmpty) return name;
    return user.email.split('@').first.trim();
  }

  int get totalViews =>
      ownerListings.fold(0, (sum, hostel) => sum + hostel.viewCount);

  @override
  void onInit() {
    super.onInit();
    
    // Use ever to reload if the current user changes (e.g. login/logout)
    // Only (re)subscribe when the signed-in uid actually changes — the
    // user doc re-emits on every profile/prefs/verification update, which
    // used to tear down and rebuild both Firestore listeners each time.
    ever(_sessionService.currentUser, (user) {
      if (user != null && user.uid != _subscribedUid) {
        _loadData(user.uid);
      }
    });

    final uid = currentUser?.uid;
    if (uid != null) {
      _loadData(uid);
    }
  }

  String? _subscribedUid;

  void _loadData(String uid) {
    _subscribedUid = uid;
    _listingsSub?.cancel();
    _activitiesSub?.cancel();

    _listingsSub = _hostelRepo.streamByOwner(uid).listen(
      (hostels) {
        ownerListings.assignAll(hostels);
      },
      onError: (e) {
        Logger.e('Error streaming owner listings in dashboard: $e');
      },
    );

    _activitiesSub = _activityRepo.streamByOwner(uid).listen(
      (activities) {
        recentActivities.assignAll(activities);
      },
      onError: (e) {
        Logger.e('Error streaming owner activities in dashboard: $e');
      },
    );
  }

  @override
  void onClose() {
    _listingsSub?.cancel();
    _activitiesSub?.cancel();
    super.onClose();
  }

  void navigateToTab(int index) {
    if (Get.isRegistered<OwnerShellController>()) {
      Get.find<OwnerShellController>().onTabSelected(index);
    }
  }
}
