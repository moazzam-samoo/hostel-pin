import 'package:get/get.dart';

class OwnerShellController extends GetxController {
  final currentIndex = 0.obs;

  void onTabSelected(int index) {
    currentIndex.value = index;
  }
}
