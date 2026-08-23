import 'package:get/get.dart';
import 'owner_shell_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../listings/listings_controller.dart';
import '../add_listing/add_listing_controller.dart';
import '../profile/owner_profile_controller.dart';

class OwnerShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OwnerShellController>(() => OwnerShellController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<ListingsController>(() => ListingsController(), fenix: true);
    Get.lazyPut<AddListingController>(() => AddListingController(), fenix: true);
    Get.lazyPut<OwnerProfileController>(() => OwnerProfileController(), fenix: true);
  }
}
