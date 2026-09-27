import 'package:get/get.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/hostel_repository.dart';
import '../../../../data/services/session_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/listing_status.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';

class AdminDashboardController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final HostelRepository _hostelRepository = Get.find<HostelRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final RxInt totalStudents = 0.obs;
  final RxInt totalOwners = 0.obs;
  final RxInt totalHostels = 0.obs;
  final RxInt activeListings = 0.obs;

  final RxMap<int, int> studentGrowth = <int, int>{}.obs;
  final RxMap<int, int> ownerGrowth = <int, int>{}.obs;

  final RxBool isLoading = true.obs;

  // A live getter over SessionService.currentUser rather than a one-time
  // copy taken in onInit — that Rxn may not have resolved yet the instant
  // this controller is constructed (its own Firestore userStream listener
  // is async), so copying once risked a permanently-blank greeting. Reading
  // through Get.find<SessionService>().currentUser.value directly inside
  // the view's Obx tracks it correctly, the same indirection-through-a-
  // getter pattern already used elsewhere in this app (e.g.
  // AdminOwnersController.ownerListingCounts).
  String get adminDisplayName {
    final name = _sessionService.currentUser.value?.displayName;
    return (name != null && name.isNotEmpty) ? name : AppStrings.adminDefaultDisplayName;
  }

  @override
  void onInit() {
    super.onInit();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    isLoading.value = true;
    try {
      final studentsCount = await _userRepository.countByRole(UserRole.student);
      final ownersCount = await _userRepository.countByRole(UserRole.owner);
      final hostelsCount = await _hostelRepository.countAll();
      final activeListingsCount = await _hostelRepository.countByStatus(ListingStatus.published);

      totalStudents.value = studentsCount;
      totalOwners.value = ownersCount;
      totalHostels.value = hostelsCount;
      activeListings.value = activeListingsCount;

      final currentYear = DateTime.now().year;
      final studentGrowthData = await _userRepository.getUserGrowth(currentYear, UserRole.student);
      final ownerGrowthData = await _userRepository.getUserGrowth(currentYear, UserRole.owner);

      studentGrowth.assignAll(studentGrowthData);
      ownerGrowth.assignAll(ownerGrowthData);
    } catch (e) {
      AppSnackbar.showGlobal(
        message: AppStrings.adminDashboardLoadError,
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
