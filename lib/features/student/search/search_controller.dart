import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/amenity.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../core/utils/logger.dart';

class SearchController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final SavedRepository _savedRepo = Get.find<SavedRepository>();
  final SessionService _sessionService = Get.find<SessionService>();

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  // Real, in-memory history of queries the user actually ran this session
  // (previously hardcoded demo values). Newest first, capped at 5.
  final recentSearches = <String>[].obs;
  
  final RxList<HostelModel> _allPublished = <HostelModel>[].obs;
  final RxSet<String> savedHostelIds = <String>{}.obs;

  // Basic filtering state
  final isSortPriceLowToHigh = false.obs;
  final isSortRatingHighToLow = false.obs;

  static const minPrice = 0.0;
  static const maxPrice = 30000.0;
  final priceRange = const RangeValues(minPrice, maxPrice).obs;
  final selectedAmenities = <Amenity>{}.obs;

  StreamSubscription? _publishedSub;
  StreamSubscription? _savedSub;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    debounce(searchQuery, (String q) => _rememberSearch(q),
        time: const Duration(seconds: 2));
    
    // Deliberately NOT paginated (FIX-7.5). Every filter on this screen —
    // query text, price range, amenities — is applied client-side over
    // `_allPublished`, so windowing this stream would not just show fewer
    // results, it would make search silently miss hostels that are outside
    // the loaded window. Bounding this one properly means moving the filters
    // server-side (real Firestore range/array queries, or a search index),
    // which is a larger change than pagination and is tracked separately.
    _publishedSub = _hostelRepo.streamAllPublished(limit: 1000).listen(
      (hostels) {
        _allPublished.assignAll(hostels);
      },
      onError: (e) {
        Logger.e('Error streaming hostels in search: $e');
      },
    );

    final uid = _sessionService.currentUser.value?.uid;
    if (uid != null) {
      _savedSub = _savedRepo.streamSaved(uid).listen(
        (saved) {
          savedHostelIds.assignAll(saved.map((s) => s.hostelId));
        },
        onError: (e) {
          Logger.e('Error streaming saved in search: $e');
        },
      );
    }
  }

  @override
  void onClose() {
    _publishedSub?.cancel();
    _savedSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // TASK-Phase-7.md Block E: deliberate scope-narrowing, not an oversight
  // — name/city/price/amenity filtering stays client-side over the full
  // streamed catalog rather than building server-side compound-filter
  // Firestore queries. Composite indexes only pay off once filtering
  // moves server-side, which isn't justified for this catalog's size yet;
  // revisit if the real hostel count grows past what's reasonable to hold
  // in memory.
  List<HostelModel> get searchResults {
    if (searchQuery.value.trim().isEmpty) return [];

    final query = searchQuery.value.toLowerCase();
    var results = _allPublished.where((h) {
      final matchesQuery = h.name.toLowerCase().contains(query) ||
          h.city.toLowerCase().contains(query);
      final matchesPrice = h.pricePerMonth >= priceRange.value.start &&
          h.pricePerMonth <= priceRange.value.end;
      final matchesAmenities = selectedAmenities.isEmpty ||
          selectedAmenities.every(h.amenities.contains);
      return matchesQuery && matchesPrice && matchesAmenities;
    }).toList();

    if (isSortPriceLowToHigh.value) {
      results.sort((a, b) => a.pricePerMonth.compareTo(b.pricePerMonth));
    } else if (isSortRatingHighToLow.value) {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return results;
  }

  void _rememberSearch(String query) {
    final q = query.trim();
    if (q.length < 3) return;
    recentSearches.removeWhere((s) => s.toLowerCase() == q.toLowerCase());
    recentSearches.insert(0, q);
    if (recentSearches.length > 5) {
      recentSearches.removeRange(5, recentSearches.length);
    }
  }

  bool isSaved(String id) => savedHostelIds.contains(id);

  void toggleSaved(String id) {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid == null) return;
    final currentlySaved = isSaved(id);

    // Optimistic UI: flip local state immediately, roll back on failure.
    if (currentlySaved) {
      savedHostelIds.remove(id);
    } else {
      savedHostelIds.add(id);
    }

    final hostel = _allPublished.firstWhereOrNull((h) => h.id == id);
    _savedRepo
        .toggleSave(uid, id, currentlySaved, hostel: hostel)
        .catchError((_) {
      if (currentlySaved) {
        savedHostelIds.add(id);
      } else {
        savedHostelIds.remove(id);
      }
    });
  }

  void toggleAmenity(Amenity amenity) {
    if (selectedAmenities.contains(amenity)) {
      selectedAmenities.remove(amenity);
    } else {
      selectedAmenities.add(amenity);
    }
  }

  void applyFilters({
    required bool sortByPrice,
    required bool sortByRating,
    required RangeValues price,
  }) {
    isSortPriceLowToHigh.value = sortByPrice;
    isSortRatingHighToLow.value = sortByRating;
    priceRange.value = price;
  }

  void resetFilters() {
    isSortPriceLowToHigh.value = false;
    isSortRatingHighToLow.value = false;
    priceRange.value = const RangeValues(minPrice, maxPrice);
    selectedAmenities.clear();
  }
}
