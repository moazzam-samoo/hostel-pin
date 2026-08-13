import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/amenity.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/services/mock_data_service.dart';

class SearchController extends GetxController {
  final _dataService = Get.find<MockDataService>();
  
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  
  final recentSearches = ['Ameerpet', 'Boys hostel', 'Under 10k'].obs;
  
  // Basic filtering state
  final isSortPriceLowToHigh = false.obs;
  final isSortRatingHighToLow = false.obs;

  static const minPrice = 0.0;
  static const maxPrice = 30000.0;
  final priceRange = const RangeValues(minPrice, maxPrice).obs;
  final selectedAmenities = <Amenity>{}.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<HostelModel> get searchResults {
    if (searchQuery.value.trim().isEmpty) return [];

    final query = searchQuery.value.toLowerCase();
    var results = _dataService.hostels.where((h) {
      final matchesQuery = h.name.toLowerCase().contains(query) || h.city.toLowerCase().contains(query);
      final matchesPrice = h.pricePerMonth >= priceRange.value.start && h.pricePerMonth <= priceRange.value.end;
      final matchesAmenities = selectedAmenities.isEmpty || selectedAmenities.every(h.amenities.contains);
      return matchesQuery && matchesPrice && matchesAmenities;
    }).toList();

    if (isSortPriceLowToHigh.value) {
      results.sort((a, b) => a.pricePerMonth.compareTo(b.pricePerMonth));
    } else if (isSortRatingHighToLow.value) {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return results;
  }

  bool isSaved(String id) => _dataService.isSaved(id);
  void toggleSaved(String id) => _dataService.toggleSaved(id);

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
