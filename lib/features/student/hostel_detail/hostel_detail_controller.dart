import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';

class HostelDetailController extends GetxController {
  late final HostelModel hostel;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is HostelModel) {
      hostel = args;
    } else {
      // Fallback or error handling
      Get.back();
    }
  }
}
