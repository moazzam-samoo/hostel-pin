import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/mock/mock_activities.dart';
import '../shell/owner_shell_controller.dart';

class DashboardController extends GetxController {
  final MockDataService _dataService = Get.find<MockDataService>();
  final SessionService _sessionService = Get.find<SessionService>();

  UserModel? get currentUser => _sessionService.currentUser.value;
  List<HostelModel> get ownerListings => _dataService.ownerListings;

  int get totalViews =>
      ownerListings.fold(0, (sum, hostel) => sum + hostel.viewCount);

  List<ActivityModel> get recentActivities => mockActivities;

  void navigateToTab(int index) {
    if (Get.isRegistered<OwnerShellController>()) {
      Get.find<OwnerShellController>().onTabSelected(index);
    }
  }
}
