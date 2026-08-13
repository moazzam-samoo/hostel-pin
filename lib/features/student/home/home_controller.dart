import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../shared/widgets/feedback/state_view.dart'; // To get StateViewStatus

class HomeController extends GetxController {
  final MockDataService _dataService = Get.find<MockDataService>();

  final Rx<StateViewStatus> status = StateViewStatus.loading.obs;

  List<HostelModel> get featuredHostels =>
      _dataService.hostels.where((h) => h.isFeatured).toList();

  List<HostelModel> get regularHostels =>
      _dataService.hostels.where((h) => !h.isFeatured).toList();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    status.value = StateViewStatus.loading;
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (_dataService.hostels.isEmpty) {
      status.value = StateViewStatus.empty;
    } else {
      status.value = StateViewStatus.content;
    }
  }

  bool isSaved(String hostelId) {
    return _dataService.isSaved(hostelId);
  }

  void toggleSaved(String hostelId) {
    _dataService.toggleSaved(hostelId);
  }
}
