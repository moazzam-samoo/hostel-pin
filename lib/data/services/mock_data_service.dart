import 'package:get/get.dart';
import '../../core/enums/user_role.dart';
import '../models/hostel_model.dart';
import '../models/user_model.dart';
import '../mock/mock_hostels.dart';
import '../mock/mock_user.dart';
import 'session_service.dart';

class MockDataService extends GetxService {
  final RxList<HostelModel> hostels = <HostelModel>[].obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // A set of saved hostel IDs to sync between Home, Saved, and Map screens.
  final RxSet<String> savedHostelIds = <String>{}.obs;

  // Filtered by the real, Firebase-authenticated owner's uid (SessionService)
  // — not this service's own `currentUser`, which is a leftover mock-era
  // field no longer kept in sync with the signed-in account. Hostel/listing
  // data itself stays mock until Phase 7; only the identity used to filter
  // "my listings" needs to be real.
  List<HostelModel> get ownerListings => hostels
      .where((h) => h.ownerId == Get.find<SessionService>().currentUser.value?.uid)
      .toList();

  Future<MockDataService> init() async {
    // Load mock data
    hostels.assignAll(mockHostels);
    currentUser.value = mockUser;
    savedHostelIds.addAll(mockUser.savedHostelIds);
    return this;
  }

  void setCurrentUserForRole(UserRole role) {
    currentUser.value = role == UserRole.student ? mockUser : mockOwnerUser;
    savedHostelIds.clear();
    if (currentUser.value != null) {
      savedHostelIds.addAll(currentUser.value!.savedHostelIds);
    }
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

  void upsertListing(HostelModel listing) {
    final index = hostels.indexWhere((h) => h.id == listing.id);
    if (index >= 0) {
      hostels[index] = listing;
    } else {
      hostels.add(listing);
    }
  }
}
