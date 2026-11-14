import '../../../../core/utils/error_code.dart';
import '../../../../core/utils/logger.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/hostel_repository.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/enums/listing_status.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';

class AdminHostelsController extends GetxController {
  final HostelRepository _hostelRepository = Get.find<HostelRepository>();

  final RxList<HostelModel> hostels = <HostelModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentLimit = 10.obs;

  @override
  void onInit() {
    super.onInit();
    _subscribeToHostels();
  }

  void _subscribeToHostels() {
    isLoading.value = true;
    _hostelRepository.streamAllAdmin(limit: currentLimit.value).listen((data) {
      hostels.assignAll(data);
      isLoading.value = false;
    }, onError: (Object e) {
      isLoading.value = false;
      Logger.e('Admin hostels load failed: $e');
      AppSnackbar.showGlobal(
          message: '${AppStrings.adminGenericLoadError} (${errorCode(e)})',
          type: SnackbarType.error);
    });
  }

  void loadMore() {
    currentLimit.value += 10;
    _subscribeToHostels();
  }

  Future<void> approve(HostelModel hostel) async {
    try {
      await _hostelRepository.setStatus(hostel.id, ListingStatus.published);
      AppSnackbar.showGlobal(
        message: AppStrings.adminHostelApproved(hostel.name),
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.showGlobal(
          message: AppStrings.adminReviewActionError, type: SnackbarType.error);
    }
  }

  Future<void> reject(HostelModel hostel, String reason) async {
    if (reason.trim().isEmpty) return;
    try {
      await _hostelRepository.setStatus(
        hostel.id,
        ListingStatus.rejected,
        rejectionReason: reason,
      );
      AppSnackbar.showGlobal(
        message: AppStrings.adminHostelRejected(hostel.name),
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.showGlobal(
          message: AppStrings.adminReviewActionError, type: SnackbarType.error);
    }
  }

  Future<void> deleteHostel(HostelModel hostel) async {
    try {
      await _hostelRepository.delete(hostel.id);
      AppSnackbar.showGlobal(
        message: AppStrings.adminUserDeleted(hostel.name),
        type: SnackbarType.success,
      );
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminGenericDeleteError, type: SnackbarType.error);
    }
  }
}
