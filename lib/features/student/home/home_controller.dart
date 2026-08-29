import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/feedback/state_view.dart';

class HomeController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final SavedRepository _savedRepo = Get.find<SavedRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final Rx<StateViewStatus> status = StateViewStatus.loading.obs;

  final RxList<HostelModel> featuredHostels = <HostelModel>[].obs;
  final RxList<HostelModel> regularHostels = <HostelModel>[].obs;
  final RxSet<String> savedHostelIds = <String>{}.obs;

  StreamSubscription? _featuredSub;
  StreamSubscription? _publishedSub;
  StreamSubscription? _savedSub;

  /// Size of the live window into `hostels` (FIX-7.5). Grows by
  /// [kHostelPageSize] each time [loadMore] is called; the stream is
  /// re-subscribed at the larger limit so every row on screen stays live.
  final RxInt pageLimit = kHostelPageSize.obs;

  /// True while the last page came back full, i.e. there may be more.
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// Widens the window by one page. No-op when the previous page came back
  /// short (nothing left) or a widen is already in flight.
  void loadMore() {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    pageLimit.value += kHostelPageSize;
    _loadData();
  }

  Future<void> _loadData() async {
    // Only show the full-screen loader for the first page — widening the
    // window must not blank out the list the user is already reading.
    if (pageLimit.value == kHostelPageSize) {
      status.value = StateViewStatus.loading;
    }

    _publishedSub?.cancel();
    _savedSub?.cancel();

    try {
      _publishedSub = _hostelRepo
          .streamAllPublished(limit: pageLimit.value)
          .listen(
        (hostels) {
          // A short page means the collection is exhausted; a full one means
          // there may be more behind it.
          hasMore.value = hostels.length >= pageLimit.value;
          isLoadingMore.value = false;

          final explicitFeatured =
              hostels.where((h) => h.isFeatured).toList();
          if (explicitFeatured.isNotEmpty) {
            featuredHostels.assignAll(explicitFeatured);
            regularHostels.assignAll(hostels.where((h) => !h.isFeatured));
          } else {
            // Fallback: If no listing has isFeatured manually set to true,
            // feature the top/first available hostels so the Featured section from Home.png is always populated.
            featuredHostels.assignAll(hostels.take(3));
            regularHostels.assignAll(hostels);
          }
          _updateStatus();
        },
        onError: (e) {
          Logger.e('Error streaming published hostels: $e');
          isLoadingMore.value = false;
          status.value = StateViewStatus.error;
        },
      );

      // Listen to saved hostels for this user to power isSaved toggle
      final uid = _sessionService.currentUser.value?.uid;
      if (uid != null) {
        _savedSub = _savedRepo.streamSaved(uid).listen(
          (saved) {
            savedHostelIds.assignAll(saved.map((s) => s.hostelId));
          },
          onError: (e) {
            Logger.e('Error streaming saved hostels: $e');
          },
        );
      }
    } catch (e) {
      status.value = StateViewStatus.error;
    }
  }

  @override
  void onClose() {
    _featuredSub?.cancel();
    _publishedSub?.cancel();
    _savedSub?.cancel();
    super.onClose();
  }

  void _updateStatus() {
    if (featuredHostels.isEmpty && regularHostels.isEmpty) {
      status.value = StateViewStatus.empty;
    } else {
      status.value = StateViewStatus.content;
    }
  }

  bool isSaved(String hostelId) {
    return savedHostelIds.contains(hostelId);
  }

  void toggleSaved(String hostelId) {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid == null) return;
    final currentlySaved = isSaved(hostelId);

    // Optimistic UI: flip local state immediately, roll back on failure.
    if (currentlySaved) {
      savedHostelIds.remove(hostelId);
    } else {
      savedHostelIds.add(hostelId);
    }

    final hostel = [...featuredHostels, ...regularHostels]
        .firstWhereOrNull((h) => h.id == hostelId);

    _savedRepo
        .toggleSave(uid, hostelId, currentlySaved, hostel: hostel)
        .catchError((_) {
      // Rollback on failure.
      if (currentlySaved) {
        savedHostelIds.add(hostelId);
      } else {
        savedHostelIds.remove(hostelId);
      }
    });
  }
}
