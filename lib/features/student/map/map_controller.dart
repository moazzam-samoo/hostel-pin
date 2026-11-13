import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/hostel_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/location_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../core/utils/hostel_marker_builder.dart';
import '../../../core/constants/app_strings.dart';

class MapController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final SavedRepository _savedRepo = Get.find<SavedRepository>();
  final SessionService _sessionService = Get.find<SessionService>();
  final LocationService _locationService = Get.find<LocationService>();

  final RxList<HostelModel> hostels = <HostelModel>[].obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<String> savedHostelIds = <String>{}.obs;
  final Rxn<HostelModel> selectedHostel = Rxn<HostelModel>();

  GoogleMapController? mapController;

  // Hyderabad, Sindh, Pakistan — matches every mock hostel's coordinates
  // (all cluster around 25.39, 68.37). Overwritten by the user's live
  // location once permission is granted, via onMapCreated -> getCurrentLocation().
  final initialPosition = const CameraPosition(
    target: LatLng(25.3960, 68.3722),
    zoom: 13,
  );
  
  // To manage the stream subscription
  StreamSubscription? _geoSubscription;
  StreamSubscription? _savedSub;

  @override
  void onInit() {
    super.onInit();
    _loadHostels();
  }

  @override
  void onClose() {
    _geoSubscription?.cancel();
    _savedSub?.cancel();
    super.onClose();
  }

  void _loadHostels() {
    // Initial fetch before map moves
    _fetchNearby(initialPosition.target.latitude, initialPosition.target.longitude, 10.0);

    final uid = _sessionService.currentUser.value?.uid;
    if (uid != null) {
      _savedSub = _savedRepo.streamSaved(uid).listen(
        (saved) {
          savedHostelIds.assignAll(saved.map((s) => s.hostelId));
        },
        onError: (e) {
          debugPrint('Error streaming saved on map: $e');
        },
      );
    }
  }

  void _fetchNearby(double lat, double lng, double radiusKm) {
    _geoSubscription?.cancel();
    _geoSubscription = _hostelRepo
        .streamNearbyHostels(lat, lng, radiusKm)
        .listen(
      (newHostels) {
        hostels.assignAll(newHostels);
        _updateMarkers();
      },
      onError: (e) {
        debugPrint('Error streaming nearby hostels: $e');
      },
    );
  }
  
  void onCameraIdle() async {
    if (mapController == null) return;
    
    // Calculate radius based on zoom level (approximate)
    // Zoom 13 ~ 10km, zoom 10 ~ 100km etc.
    final region = await mapController!.getVisibleRegion();
    final centerLat = (region.northeast.latitude + region.southwest.latitude) / 2;
    final centerLng = (region.northeast.longitude + region.southwest.longitude) / 2;
    
    // For simplicity, fixed 20km radius on move, or we could calculate based on bounds.
    _fetchNearby(centerLat, centerLng, 20.0);
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
    // Centre on the user only if they have already granted location — never
    // pop a permission prompt the instant the map appears. First-time users
    // are asked when they tap the "my location" button.
    _locationService.hasPermission().then((granted) {
      if (granted) getCurrentLocation();
    });
  }

  Future<void> getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    
    if (position == null) {
      // Denied, denied-forever or the device location switch is off: the app
      // cannot re-prompt, so offer the one thing that can actually fix it.
      final openIt = await _showLocationRationale();
      if (openIt == true) await _locationService.openSettings();
      return;
    }
    
    try {
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
          message: 'Could not update camera position.', type: SnackbarType.error);
    }
  }

  Future<bool?> _showLocationRationale() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text(AppStrings.locationSettingsTitle),
        content: const Text(AppStrings.locationSettingsMessage),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(AppStrings.notNow)),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(AppStrings.openSettings)),
        ],
      ),
    );
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

    final hostel = hostels.firstWhereOrNull((h) => h.id == id);
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
}
