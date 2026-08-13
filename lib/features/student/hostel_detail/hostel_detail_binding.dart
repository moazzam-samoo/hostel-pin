import 'package:get/get.dart';
import 'hostel_detail_controller.dart';

class HostelDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HostelDetailController>(() => HostelDetailController());
  }
}
