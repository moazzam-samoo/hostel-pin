import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_finder_app/data/repositories/hostel_repository.dart';
import 'package:hostel_finder_app/data/repositories/saved_repository.dart';
import 'package:hostel_finder_app/data/services/location_service.dart';
import 'package:hostel_finder_app/data/services/session_service.dart';
import 'package:hostel_finder_app/features/student/map/map_controller.dart';

class _FakeSession extends SessionService {
  @override
  void wireAuthState() {}
}

class _GrantedLocation extends LocationService {
  @override
  Future<bool> hasPermission() async => true;
  @override
  Future<Position?> getCurrentLocation() async => Position(
        longitude: 68.37,
        latitude: 25.39,
        timestamp: DateTime(2026, 1, 1),
        accuracy: 1,
        altitude: 0,
        altitudeAccuracy: 1,
        heading: 0,
        headingAccuracy: 1,
        speed: 0,
        speedAccuracy: 1,
      );
}

/// A map whose platform view is not ready: every call fails.
class _BrokenMap implements GoogleMapController {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('map not ready');
}

void main() {
  testWidgets(
      'an automatic recentre that fails stays silent (no red snackbar on Home)',
      (tester) async {
    Get.reset();
    final db = FakeFirebaseFirestore();
    Get.put(HostelRepository(firestore: db));
    Get.put(SavedRepository(firestore: db));
    Get.put<SessionService>(_FakeSession());
    Get.put<LocationService>(_GrantedLocation());
    final c = Get.put(MapController());

    await tester.pumpWidget(const GetMaterialApp(
        home: Scaffold(body: SizedBox()), enableLog: false));
    await tester.pump();

    c.onMapCreated(_BrokenMap());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Could not update camera position.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
