import 'dart:async';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/enums/availability_status.dart';
import '../../../core/enums/listing_status.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/models/saved_model.dart';
import '../../../data/models/upload_result_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../core/utils/logger.dart';

class SavedController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final SavedRepository _savedRepo = Get.find<SavedRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  // Sourced straight from the denormalized `saved` stream (Block B.3/C.2)
  // — no second read against `hostels` to render this list.
  final RxList<HostelModel> savedHostels = <HostelModel>[].obs;
  final RxSet<String> savedHostelIds = <String>{}.obs;

  // Only needed for "You might also like" (suggestions minus what's
  // already saved) — that screen genuinely needs the full catalog, per
  // TASK-Phase-7.md Block E's own note on SavedController.
  final RxList<HostelModel> _allPublished = <HostelModel>[].obs;

  StreamSubscription? _publishedSub;
  StreamSubscription? _savedSub;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onClose() {
    _publishedSub?.cancel();
    _savedSub?.cancel();
    super.onClose();
  }

  void _loadData() {
    _publishedSub = _hostelRepo.streamAllPublished().listen(
      (hostels) {
        _allPublished.assignAll(hostels);
      },
      onError: (Object e) => Logger.e('Saved: published stream error: $e'),
    );

    final uid = _sessionService.currentUser.value?.uid;
    if (uid != null) {
      _savedSub = _savedRepo.streamSaved(uid).listen(
        (saved) {
          savedHostelIds.assignAll(saved.map((s) => s.hostelId));
          savedHostels.assignAll(saved.map(_toHostelModel));
        },
        onError: (Object e) => Logger.e('Saved: saved stream error: $e'),
      );
    }
  }

  /// Builds a display-only `HostelModel` from a saved doc's denormalized
  /// summary — enough for `HostelCard`'s `saved` layout (image/name/owner)
  /// with zero extra reads. Fields the summary doesn't carry (description,
  /// amenities, contact, etc.) are left at safe defaults; this object is
  /// for rendering the Saved list, not for feeding Hostel Detail.
  HostelModel _toHostelModel(SavedModel s) {
    return HostelModel(
      id: s.hostelId,
      ownerId: '',
      ownerName: s.ownerName,
      name: s.name,
      fullAddress: '',
      city: s.city,
      latitude: 0,
      longitude: 0,
      description: '',
      pricePerMonth: s.price,
      // Saved's HostelCard usage always indexes photos.first — keep this
      // list non-empty even when coverPhoto is blank so that never throws;
      // NetworkImageBox already falls back to a placeholder for a blank/
      // invalid URL.
      photos: [UploadResultModel(url: s.coverPhoto, publicId: '')],
      amenities: const {},
      availability: AvailabilityStatus.available,
      contactPhone: '',
      contactWhatsapp: '',
      rating: s.rating,
      status: ListingStatus.published,
    );
  }

  // "You might also like" renders regardless of whether the saved list
  // itself is empty or populated, per the mockup.
  List<HostelModel> get suggestedHostels => _allPublished
      .where((h) => !savedHostelIds.contains(h.id))
      .take(4)
      .toList();

  void removeSaved(String id) {
    toggleSaved(id);
  }

  /// `savedHostels` cards are built from the saved doc's lean denormalized
  /// summary (no description/amenities/contact) — good enough to render
  /// the card, not good enough to feed Hostel Detail. `_allPublished`
  /// already streams the full catalog for `suggestedHostels`, so the full
  /// object is normally already in memory; fall back to a single `getById`
  /// read only if that stream hasn't caught up yet.
  Future<void> openHostelDetail(String id) async {
    final full = _allPublished.firstWhereOrNull((h) => h.id == id) ??
        await _hostelRepo.getById(id);
    if (full != null) {
      Get.toNamed(Routes.studentHostelDetail, arguments: full);
    }
  }

  bool isSaved(String id) => savedHostelIds.contains(id);

  void toggleSaved(String id) {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid == null) return;
    final currentlySaved = isSaved(id);

    // Optimistic UI: flip local state immediately, roll back on failure.
    final removedHostel = currentlySaved
        ? savedHostels.firstWhereOrNull((h) => h.id == id)
        : null;
    if (currentlySaved) {
      savedHostelIds.remove(id);
      savedHostels.removeWhere((h) => h.id == id);
    } else {
      savedHostelIds.add(id);
    }

    final hostel = _allPublished.firstWhereOrNull((h) => h.id == id);
    _savedRepo
        .toggleSave(uid, id, currentlySaved, hostel: hostel)
        .catchError((_) {
      if (currentlySaved) {
        savedHostelIds.add(id);
        if (removedHostel != null) savedHostels.add(removedHostel);
      } else {
        savedHostelIds.remove(id);
      }
    });
  }
}
