import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hostel_finder_app/core/enums/amenity.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/repositories/saved_repository.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/features/student/search/search_controller.dart'
    as app;

class _FakeSession extends SessionService {
  @override
  void wireAuthState() {}
}

Future<void> _seed(FakeFirebaseFirestore db, String id, String name,
    {List<String> amenities = const [], num price = 10000, String city = 'Hyderabad'}) {
  return db.collection('hostels').doc(id).set({
    'status': 'published',
    'name': name,
    'city': city,
    'pricePerMonth': price,
    'amenities': amenities,
  });
}

Future<app.SearchController> _controller(FakeFirebaseFirestore db) async {
  Get.reset();
  Get.put(HostelRepository(firestore: db));
  Get.put(SavedRepository(firestore: db));
  Get.put<SessionService>(_FakeSession());
  final c = Get.put(app.SearchController());
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return c;
}

void main() {
  late FakeFirebaseFirestore db;

  setUp(() async {
    db = FakeFirebaseFirestore();
    await _seed(db, '1001', 'Wifi Hostel', amenities: ['wifi', 'meals']);
    await _seed(db, '1002', 'Plain Hostel');
    await _seed(db, '1003', 'Gym Hostel', amenities: ['wifi', 'gym'], price: 45000);
  });

  test('with no query and no filters nothing is listed', () async {
    final c = await _controller(db);
    expect(c.showResults, isFalse);
    expect(c.searchResults, isEmpty);
  });

  test('selecting an amenity WITHOUT typing a query lists matching hostels',
      () async {
    final c = await _controller(db);
    c.selectedAmenities.add(Amenity.wifi);
    expect(c.showResults, isTrue);
    expect(c.searchResults.map((h) => h.name).toSet(),
        {'Wifi Hostel', 'Gym Hostel'});
  });

  test('several amenities must all match', () async {
    final c = await _controller(db);
    c.selectedAmenities.addAll({Amenity.wifi, Amenity.gym});
    expect(c.searchResults.map((h) => h.name), ['Gym Hostel']);
  });

  test('amenities combine with a text query', () async {
    final c = await _controller(db);
    c.searchQuery.value = 'wifi';
    c.selectedAmenities.add(Amenity.meals);
    expect(c.searchResults.map((h) => h.name), ['Wifi Hostel']);
  });

  test('the default price range does not hide expensive hostels', () async {
    final c = await _controller(db);
    c.searchQuery.value = 'hostel';
    expect(c.searchResults.map((h) => h.name).toSet(),
        {'Wifi Hostel', 'Plain Hostel', 'Gym Hostel'});
  });

  test('a narrowed price range filters, with or without a query', () async {
    final c = await _controller(db);
    c.priceRange.value = const RangeValues(0, 20000);
    expect(c.showResults, isTrue);
    expect(c.searchResults.map((h) => h.name).toSet(),
        {'Wifi Hostel', 'Plain Hostel'});
  });

  test('resetFilters clears everything and the empty state returns', () async {
    final c = await _controller(db);
    c.selectedAmenities.add(Amenity.wifi);
    c.resetFilters();
    expect(c.showResults, isFalse);
    expect(c.searchResults, isEmpty);
  });
}
