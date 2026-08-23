import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../core/utils/logger.dart';
import '../shell/owner_shell_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/feedback/confirm_dialog.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class ListingsController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final RxList<HostelModel> ownerListings = <HostelModel>[].obs;
  StreamSubscription? _listingsSub;

  @override
  void onInit() {
    super.onInit();
    
    ever(_sessionService.currentUser, (user) {
      if (user != null) {
        _loadData(user.uid);
      }
    });

    final uid = _sessionService.currentUser.value?.uid;
    if (uid != null) {
      _loadData(uid);
    }
  }

  void _loadData(String uid) {
    _listingsSub?.cancel();
    _listingsSub = _hostelRepo.streamByOwner(uid).listen(
      (hostels) {
        ownerListings.assignAll(hostels);
      },
      onError: (e) {
        Logger.e('Error streaming owner listings in listings screen: $e');
      },
    );
  }

  @override
  void onClose() {
    _listingsSub?.cancel();
    super.onClose();
  }

  void deleteListing(HostelModel hostel) {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.deleteListingTitle,
        message: AppStrings.deleteListingMessage,
        confirmText: AppStrings.deleteButton,
        isDestructive: true,
        onConfirm: () async {
          Get.back();
          try {
            await _hostelRepo.delete(hostel.id);
            AppSnackbar.showGlobal(
                message: AppStrings.listingDeletedMessage,
                type: SnackbarType.success);
          } catch (e) {
            AppSnackbar.showGlobal(
                message: 'Failed to delete listing', type: SnackbarType.error);
          }
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  void editListing(HostelModel hostel) {
    Get.toNamed(Routes.ownerEdit, arguments: hostel);
  }

  void navigateToAddListing() {
    if (Get.isRegistered<OwnerShellController>()) {
      Get.find<OwnerShellController>().onTabSelected(2);
    }
  }
}
