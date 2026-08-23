import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class HostelDetailController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final SavedRepository _savedRepo = Get.find<SavedRepository>();
  final SessionService _sessionService = Get.find<SessionService>();
  
  late final HostelModel hostel;
  final isSaved = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is HostelModel) {
      hostel = args;
      // Fire and forget view increment
      _hostelRepo.incrementViews(hostel.id);
      _checkSavedStatus();
    } else {
      // Fallback or error handling
      Get.back();
    }
  }

  void _checkSavedStatus() {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid != null) {
      _savedRepo.streamSaved(uid).listen((savedList) {
        isSaved.value = savedList.any((s) => s.hostelId == hostel.id);
      });
    }
  }

  void toggleSaved() {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid == null) {
      AppSnackbar.showGlobal(
        message: 'Please sign in to save hostels',
        type: SnackbarType.info,
      );
      return;
    }

    final currentlySaved = isSaved.value;
    // Optimistic update
    isSaved.value = !currentlySaved;

    _savedRepo
        .toggleSave(uid, hostel.id, currentlySaved, hostel: hostel)
        .catchError((e) {
      // Rollback on failure
      isSaved.value = currentlySaved;
      AppSnackbar.showGlobal(
        message: 'Failed to update saved status',
        type: SnackbarType.error,
      );
    });
  }
}
