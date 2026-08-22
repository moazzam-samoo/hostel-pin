import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../shell/owner_shell_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/feedback/confirm_dialog.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class ListingsController extends GetxController {
  final MockDataService _dataService = Get.find<MockDataService>();

  List<HostelModel> get ownerListings => _dataService.ownerListings;

  void deleteListing(HostelModel hostel) {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.deleteListingTitle,
        message: AppStrings.deleteListingMessage,
        confirmText: AppStrings.deleteButton,
        isDestructive: true,
        onConfirm: () {
          Get.back();
          _dataService.hostels.removeWhere((h) => h.id == hostel.id);
          // Note: Opting for standard AppSnackbar instead of Undo pattern
          // as per Phase 3's accepted gap.
          AppSnackbar.showGlobal(
              message: AppStrings.listingDeletedMessage,
              type: SnackbarType.success);
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
