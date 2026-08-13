import 'package:get/get.dart';
import '../models/hostel_model.dart';
import '../models/user_model.dart';
import '../mock/mock_hostels.dart';
import '../mock/mock_user.dart';

class MockDataService extends GetxService {
  final RxList<HostelModel> hostels = <HostelModel>[].obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  // A set of saved hostel IDs to sync between Home, Saved, and Map screens.
  final RxSet<String> savedHostelIds = <String>{}.obs;

  Future<MockDataService> init() async {
    // Load mock data
    hostels.assignAll(mockHostels);
    currentUser.value = mockUser;
    savedHostelIds.addAll(mockUser.savedHostelIds);
    return this;
  }

  void toggleSaved(String hostelId) {
    if (savedHostelIds.contains(hostelId)) {
      savedHostelIds.remove(hostelId);
    } else {
      savedHostelIds.add(hostelId);
    }
  }

  bool isSaved(String hostelId) {
    return savedHostelIds.contains(hostelId);
  }
}
