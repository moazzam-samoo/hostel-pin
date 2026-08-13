import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class MapController extends GetxController {
  final _dataService = Get.find<MockDataService>();
  
  final hostels = <HostelModel>[].obs;
  final markers = <Marker>{}.obs;
  final selectedHostel = Rxn<HostelModel>();
  
  GoogleMapController? mapController;
  
  // Default to Hyderabad or center of mock data
  final initialPosition = const CameraPosition(
    target: LatLng(17.3850, 78.4867),
    zoom: 12,
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

  void _updateMarkers() {
    // TODO(map-fidelity): the mockup calls for a custom bitmap marker (a
    // name chip above a teardrop pin, pre-rendered per (name, selected) and
    // cached) plus a custom terracotta/white/teal map style JSON. Both are
    // real design work, not a quick code fix — see IMPLEMENTATION_PLAN.md
    // §3.E. This uses hue-differentiated default markers as an interim step
    // so selection is at least visually distinguishable.
    markers.assignAll(hostels.map((hostel) {
      final isSelected = selectedHostel.value?.id == hostel.id;
      return Marker(
        markerId: MarkerId(hostel.id),
        position: LatLng(hostel.latitude, hostel.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueViolet,
        ),
        infoWindow: InfoWindow(
          title: hostel.name,
          snippet: 'Rs ${hostel.pricePerMonth}/month',
        ),
        onTap: () {
          selectedHostel.value = hostel;
          _updateMarkers();
        },
      );
    }));
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppSnackbar.showGlobal(message: 'Please enable location services.', type: SnackbarType.error);
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
        AppSnackbar.showGlobal(message: 'Location permissions are denied.', type: SnackbarType.error);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppSnackbar.showGlobal(message: 'Location permissions are permanently denied.', type: SnackbarType.error);
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
      AppSnackbar.showGlobal(message: 'Could not get current location.', type: SnackbarType.error);
    }
  }

  Future<bool?> _showLocationRationale() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Allow Location Access'),
        content: const Text(
          'Hostel Finder uses your location to show nearby hostels on the map and center it on you.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Not Now')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Continue')),
        ],
      ),
    );
  }

  bool isSaved(String id) => _dataService.isSaved(id);
  void toggleSaved(String id) => _dataService.toggleSaved(id);
}
