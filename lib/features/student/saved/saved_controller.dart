import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/services/mock_data_service.dart';

class SavedController extends GetxController {
  final _dataService = Get.find<MockDataService>();
  
  final savedHostels = <HostelModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(_dataService.savedHostelIds, (_) {
      _loadSavedHostels();
    });
    _loadSavedHostels();
  }

  void _loadSavedHostels() {
    savedHostels.value = _dataService.hostels
        .where((h) => _dataService.isSaved(h.id))
        .toList();
  }

  // "You might also like" renders regardless of whether the saved list
  // itself is empty or populated, per the mockup.
  List<HostelModel> get suggestedHostels => _dataService.hostels
      .where((h) => !_dataService.isSaved(h.id))
      .take(4)
      .toList();

  void removeSaved(String id) {
    _dataService.toggleSaved(id);
  }

  bool isSaved(String id) => _dataService.isSaved(id);
  void toggleSaved(String id) => _dataService.toggleSaved(id);
}
