import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../core/utils/hostel_marker_builder.dart';
import '../../../core/constants/app_strings.dart';

class MapController extends GetxController {
  final _dataService = Get.find<MockDataService>();

  final hostels = <HostelModel>[].obs;
  final markers = <Marker>{}.obs;
  final selectedHostel = Rxn<HostelModel>();

  GoogleMapController? mapController;

  // Hyderabad, Sindh, Pakistan — matches every mock hostel's coordinates
  // (all cluster around 25.39, 68.37). Overwritten by the user's live
  // location once permission is granted, via onMapCreated -> getCurrentLocation().
  final initialPosition = const CameraPosition(
    target: LatLng(25.3960, 68.3722),
    zoom: 13,
  );

  @override
  void onInit() {
    super.onInit();
    _loadHostels();
  }

  void _loadHostels() {
    hostels.value = _dataService.hostels;
    _updateMarkers();
  }

  final Map<String, BitmapDescriptor> _markerBitmapCache = {};

  Future<void> _updateMarkers() async {
    final newMarkers = <Marker>{};
    for (var hostel in hostels) {
      final isSelected = selectedHostel.value?.id == hostel.id;
      final cacheKey = '${hostel.id}_$isSelected';

      BitmapDescriptor bitmap;
      if (_markerBitmapCache.containsKey(cacheKey)) {
        bitmap = _markerBitmapCache[cacheKey]!;
      } else {
        bitmap = await buildHostelMarkerBitmap(
          name: hostel.name,
          isSelected: isSelected,
        );
        _markerBitmapCache[cacheKey] = bitmap;
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(hostel.id),
          position: LatLng(hostel.latitude, hostel.longitude),
          icon: bitmap,
          onTap: () {
            selectedHostel.value = hostel;
            _updateMarkers();
          },
        ),
      );
    }
    markers.assignAll(newMarkers);
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Proactively ask for location permission and center on the user's
    // real position as soon as the map is ready, instead of waiting for
    // an explicit FAB tap.
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppSnackbar.showGlobal(
          message: 'Please enable location services.',
          type: SnackbarType.error);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show a rationale before the OS permission prompt (§3.E — this was
      // previously undesigned/unaddressed).
      final shouldRequest = await _showLocationRationale();
      if (shouldRequest != true) return;

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppSnackbar.showGlobal(
            message: 'Location permissions are denied.',
            type: SnackbarType.error);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppSnackbar.showGlobal(
          message: 'Location permissions are permanently denied.',
          type: SnackbarType.error);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          ),
        ),
      );
    } catch (e) {
      AppSnackbar.showGlobal(
          message: 'Could not get current location.', type: SnackbarType.error);
    }
  }

  Future<bool?> _showLocationRationale() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.allowLocationAccess),
        content: const Text(
          'Hostel Finder uses your location to show nearby hostels on the map and center it on you.',
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(AppStrings.notNow)),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(AppStrings.continueText)),
        ],
      ),
    );
  }

  bool isSaved(String id) => _dataService.isSaved(id);
  void toggleSaved(String id) => _dataService.toggleSaved(id);
}
