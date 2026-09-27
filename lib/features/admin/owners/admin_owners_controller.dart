import 'package:get/get.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/hostel_repository.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';

class AdminOwnersController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final HostelRepository _hostelRepository = Get.find<HostelRepository>();

  final RxList<UserModel> owners = <UserModel>[].obs;
  // Map uid to number of listings
  final RxMap<String, int> ownerListingCounts = <String, int>{}.obs;
  
  final RxBool isLoading = true.obs;
  final RxInt currentLimit = 10.obs;

  @override
  void onInit() {
    super.onInit();
    _subscribeToOwners();
  }

  void _subscribeToOwners() {
    isLoading.value = true;
    _userRepository.streamAllUsers(limit: currentLimit.value, roleFilter: UserRole.owner).listen((data) async {
      owners.assignAll(data);
      // Fetch listing counts for any owners not already cached.
      for (var owner in data) {
        if (!ownerListingCounts.containsKey(owner.uid)) {
          _fetchListingCount(owner.uid);
        }
      }
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      AppSnackbar.showGlobal(message: AppStrings.adminGenericLoadError, type: SnackbarType.error);
    });
  }
  
  void _fetchListingCount(String ownerId) async {
    // A one-off count() per visible owner row — a genuine per-row read,
    // recorded as a known perf question rather than silently solved (Block
    // E.3), same discipline as this project's other deliberately-unpaginated
    // per-owner reads (AGENTS.md's Phase 7 trap #2).
    ownerListingCounts[ownerId] = await _hostelRepository.countByOwner(ownerId);
  }

  void loadMore() {
    currentLimit.value += 10;
    _subscribeToOwners();
  }

  Future<void> toggleUserStatus(UserModel user) async {
    final newStatus = user.status == 'blocked' ? 'active' : 'blocked';
    try {
      await _userRepository.updateStatus(user.uid, newStatus);
      AppSnackbar.showGlobal(
        message: AppStrings.adminUserStatusUpdated(user.displayName, newStatus),
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminGenericUpdateError, type: SnackbarType.error);
    }
  }

  Future<void> deleteOwner(UserModel user) async {
    try {
      await _userRepository.deleteUserDoc(user.uid);
      AppSnackbar.showGlobal(
        message: AppStrings.adminUserDeleted(user.displayName),
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminGenericDeleteError, type: SnackbarType.error);
    }
  }
}
