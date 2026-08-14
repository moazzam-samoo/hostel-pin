import 'package:get/get.dart';
import 'listings_controller.dart';

class ListingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListingsController>(() => ListingsController());
  }
}
