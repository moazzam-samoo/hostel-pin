import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show setEquals, listEquals;
import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/models/upload_result_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/location_service.dart';
import 'widgets/location_source_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/enums/amenity.dart';
import '../../../core/enums/listing_status.dart';
import '../../../core/enums/availability_status.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/cloudinary_thumbnail.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// H.3 decision: option (b) — "Real". google_maps_flutter was already a paid
// dependency (added in Phase 3 for the student Map tab), so the location
// picker below is a genuine interactive GoogleMap with a fixed center pin;
// "Confirm location" returns the map's current center LatLng via
// Get.back(result: latLng) instead of a hardcoded stand-in. See
// widgets/location_picker_view.dart.
class AddListingController extends GetxController {
  final _hostelRepo = Get.find<HostelRepository>();
  final _activityRepo = Get.find<ActivityRepository>();
  final _sessionService = Get.find<SessionService>();
  final _storageService = Get.find<StorageService>();
  final _locationService = Get.find<LocationService>();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  /// Per-file upload progress for the publish batch (FIX-7.14).
  /// `uploadIndex` is 1-based and `uploadTotal` is 0 when nothing is
  /// uploading, so the UI can render "Uploading photo 2 of 5 — 40%".
  final uploadProgress = 0.0.obs;
  final uploadIndex = 0.obs;
  final uploadTotal = 0.obs;

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final roomsController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();

  final selectedAmenities = <Amenity>{}.obs;
  final sameAsPhone = false.obs;
  final availability = AvailabilityStatus.available.obs;

  // Holds both existing network photos (with publicId) and local picked files (empty publicId)
  final photos = <UploadResultModel>[].obs;

  // Location
  final latitude = 25.3960.obs;
  final longitude = 68.3722.obs;
  final hasPickedLocation = false.obs;

  /// City resolved by reverse-geocoding whatever location the owner pinned
  /// (FIX-7.13/FIX-7.15). Authoritative when present: coordinates the owner
  /// actually dropped a pin on beat `_extractCity`'s string-guessing at the
  /// typed address. Empty when geocoding is unavailable or found nothing.
  final resolvedCity = ''.obs;

  final ImagePicker _picker = ImagePicker();

  HostelModel? _editingHostel;
  bool get isEditMode => _editingHostel != null;

  String _initialName = '';
  String _initialAddress = '';
  String _initialDescription = '';
  String _initialPrice = '';
  String _initialRooms = '';
  String _initialPhone = '';
  String _initialWhatsapp = '';
  Set<Amenity> _initialAmenities = const {};
  List<UploadResultModel> _initialPhotos = const [];

  @override
  void onInit() {
    super.onInit();

    // Check if we are editing an existing hostel
    if (Get.arguments is HostelModel) {
      _editingHostel = Get.arguments as HostelModel;
      _populateForm(_editingHostel!);
    }

    _initialName = nameController.text;
    _initialAddress = addressController.text;
    _initialDescription = descriptionController.text;
    _initialPrice = priceController.text;
    _initialRooms = roomsController.text;
    _initialPhone = phoneController.text;
    _initialWhatsapp = whatsappController.text;
    _initialAmenities = Set.of(selectedAmenities);
    _initialPhotos = List.of(photos);

    ever(sameAsPhone, (isSame) {
      if (isSame) {
        whatsappController.text = phoneController.text;
      }
    });

    phoneController.addListener(() {
      if (sameAsPhone.value) {
        whatsappController.text = phoneController.text;
      }
      update();
    });
    for (final c in [
      nameController,
      addressController,
      descriptionController,
      priceController,
      roomsController,
      whatsappController
    ]) {
      c.addListener(update);
    }
    // photos/selectedAmenities are Rx collections — re-run isValid whenever
    // either mutates so the Publish button's isDisabled state stays live.
    ever(photos, (_) => update());
    ever(selectedAmenities, (_) => update());
  }

  /// Whether every field required to publish currently passes its
  /// validator, driving the Publish button's isDisabled state.
  bool get isValid {
    return Validators.required(nameController.text) == null &&
        Validators.required(addressController.text) == null &&
        Validators.required(descriptionController.text) == null &&
        Validators.price(priceController.text) == null &&
        Validators.rooms(roomsController.text) == null &&
        Validators.phone(phoneController.text) == null &&
        (sameAsPhone.value || Validators.phone(whatsappController.text) == null) &&
        photos.length >= 3 &&
        photos.length <= 10;
  }

  /// Whether the form differs from its initial (edit-mode prefill, or
  /// blank-create) state — drives the unsaved-changes guard on back nav.
  bool get hasUnsavedChanges {
    return nameController.text != _initialName ||
        addressController.text != _initialAddress ||
        descriptionController.text != _initialDescription ||
        priceController.text != _initialPrice ||
        roomsController.text != _initialRooms ||
        phoneController.text != _initialPhone ||
        whatsappController.text != _initialWhatsapp ||
        !setEquals(selectedAmenities.toSet(), _initialAmenities) ||
        !listEquals(photos.toList(), _initialPhotos);
  }

  void _populateForm(HostelModel hostel) {
    nameController.text = hostel.name;
    addressController.text = hostel.fullAddress;
    descriptionController.text = hostel.description;
    priceController.text = hostel.pricePerMonth.toString();
    roomsController.text = hostel.totalRooms.toString();
    phoneController.text = hostel.contactPhone;
    whatsappController.text = hostel.contactWhatsapp;
    selectedAmenities.assignAll(hostel.amenities);
    photos.assignAll(hostel.photos);
    latitude.value = hostel.latitude;
    longitude.value = hostel.longitude;
    hasPickedLocation.value = true;
    availability.value = hostel.availability;
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    roomsController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    super.onClose();
  }

  void toggleAvailability(bool isAvailable) {
    availability.value =
        isAvailable ? AvailabilityStatus.available : AvailabilityStatus.full;
  }

  void toggleAmenity(Amenity amenity) {
    if (selectedAmenities.contains(amenity)) {
      selectedAmenities.remove(amenity);
    } else {
      selectedAmenities.add(amenity);
    }
  }

  /// Tapping the location panel offers a choice — live GPS position, or
  /// drag-a-pin on the full-screen map — rather than always jumping
  /// straight to the map.
  Future<void> pickLocation() async {
    final source = await showLocationSourceSheet();
    switch (source) {
      case LocationSource.currentLocation:
        await _useCurrentLocation();
      case LocationSource.chooseOnMap:
        await _chooseOnMap();
      case null:
        break; // sheet dismissed without a choice
    }
  }

  Future<void> _useCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      AppSnackbar.showGlobal(
        message: AppStrings.errorLocationUnavailable,
        type: SnackbarType.error,
      );
      return;
    }
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    hasPickedLocation.value = true;
    await _resolvePinnedPlace();
  }

  /// Reverse-geocodes the pinned coordinates to fill `city`, and to offer the
  /// owner a starting address when they haven't typed one (FIX-7.13). Never
  /// overwrites an address the owner already wrote, and never blocks or
  /// errors — an unresolved place just leaves `city` to the text heuristic.
  Future<void> _resolvePinnedPlace() async {
    final place = await _locationService.resolvePlace(
      latitude.value,
      longitude.value,
    );
    if (place == null) return;

    if (place.city != null && place.city!.isNotEmpty) {
      resolvedCity.value = place.city!;
    }
    if (addressController.text.trim().isEmpty &&
        place.formattedAddress != null) {
      addressController.text = place.formattedAddress!;
    }
  }

  Future<void> _chooseOnMap() async {
    // NOTE: do NOT add a type argument here (`Get.toNamed<LatLng>`).
    // GetMaterialApp generates every route through a RouteFactory that
    // returns Route<dynamic>?, so a page is always built as
    // GetPageRoute<dynamic> — typing the GetPage does not change that.
    // Navigator.pushNamed<T> then does `onGenerateRoute(settings) as
    // Route<T?>?`, and casting GetPageRoute<dynamic> to Route<LatLng?>
    // throws. Because nothing awaits this call from the InkWell's onTap,
    // that surfaced only as an unhandled async error, so the picker
    // never opened and no failure was visible in the UI.
    final result = await Get.toNamed(
      Routes.ownerLocationPicker,
      arguments: hasPickedLocation.value
          ? LatLng(latitude.value, longitude.value)
          : null,
    );
    if (result is LatLng) {
      latitude.value = result.latitude;
      longitude.value = result.longitude;
      hasPickedLocation.value = true;
      await _resolvePinnedPlace();
    }
  }

  Future<void> pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      for (var image in selectedImages) {
        if (photos.length < 10) {
          photos.add(UploadResultModel(url: image.path, publicId: ''));
        } else {
          AppSnackbar.showGlobal(
              message: AppStrings.errorMaxPhotos, type: SnackbarType.error);
          break;
        }
      }
    }
  }

  void saveAsDraft() {
    _saveListing(ListingStatus.draft);
  }

  void publishListing() {
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.showGlobal(
        message: 'Please check the highlighted fields above.',
        type: SnackbarType.error,
      );
      return;
    }
    if (photos.length < 3) {
      AppSnackbar.showGlobal(
        message: AppStrings.errorMinPhotos,
        type: SnackbarType.error,
      );
      return;
    }
    if (photos.length > 10) {
      AppSnackbar.showGlobal(
        message: AppStrings.errorMaxPhotos,
        type: SnackbarType.error,
      );
      return;
    }
    _saveListing(ListingStatus.published);
  }

  Future<void> _saveListing(ListingStatus status) async {
    final uid = _sessionService.currentUser.value?.uid ?? 'mock_owner_id';
    final ownerName =
        _sessionService.currentUser.value?.displayName ?? 'Anonymous';

    isLoading.value = true;
    try {
      // 1. Upload new photos.
      // Photos already carrying a publicId are untouched; only locally
      // picked files are uploaded, in one batch so a mid-way failure can
      // report exactly which assets were orphaned (FIX-7.8), with per-file
      // progress surfaced to the UI (FIX-7.14).
      final pendingIndices = <int>[];
      final pendingFiles = <File>[];
      for (var i = 0; i < photos.length; i++) {
        if (photos[i].publicId.isEmpty) {
          pendingIndices.add(i);
          pendingFiles.add(File(photos[i].url));
        }
      }

      final uploadedPhotos = List<UploadResultModel>.from(photos);
      if (pendingFiles.isNotEmpty) {
        uploadTotal.value = pendingFiles.length;
        final results = await _storageService.uploadImages(
          pendingFiles,
          'hostels',
          onFileProgress: (index, progress) {
            uploadIndex.value = index + 1;
            uploadProgress.value = progress;
          },
        );
        for (var i = 0; i < pendingIndices.length; i++) {
          uploadedPhotos[pendingIndices[i]] = results[i];
        }
      }

      // description has a real form field (descriptionController), shown to
      // students on Hostel Detail via AboutSection. `city` has no dedicated
      // input either, but it is no longer pure string-guessing (FIX-7.15):
      // if the owner pinned a location we reverse-geocode it and trust that;
      // `_extractCity` is now only the fallback for when geocoding returned
      // nothing (offline, no Play Services, unmapped coordinates).
      final geohash = _locationService.getGeohash(latitude.value, longitude.value);
      final rawAddress = addressController.text.trim();
      final extractedCity = resolvedCity.value.isNotEmpty
          ? resolvedCity.value
          : _extractCity(rawAddress);

      final hostel = HostelModel(
        id: _editingHostel?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: uid,
        ownerName: ownerName,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        fullAddress: rawAddress,
        city: _editingHostel?.city ?? extractedCity,
        pricePerMonth: double.tryParse(priceController.text) ?? 0.0,
        totalRooms: int.tryParse(roomsController.text) ?? 1,
        rating: _editingHostel?.rating ?? 0.0,
        reviewCount: _editingHostel?.reviewCount ?? 0,
        viewCount: _editingHostel?.viewCount ?? 0,
        contactPhone: phoneController.text.trim(),
        contactWhatsapp: whatsappController.text.trim(),
        latitude: latitude.value,
        longitude: longitude.value,
        amenities: selectedAmenities.toSet(),
        photos: uploadedPhotos,
        availability: availability.value,
        status: status,
        location: GeoPoint(latitude.value, longitude.value),
        geohash: geohash,
      );

      if (_editingHostel == null) {
        await _hostelRepo.create(hostel);
        if (status == ListingStatus.published) {
          // Log activity for creation
          final activity = ActivityModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            ownerId: uid,
            type: 'listing_created',
            title: 'New Listing Published',
            message: 'You published ${hostel.name}.',
            hostelId: hostel.id,
            hostelName: hostel.name,
            thumbnailUrl: hostel.photos.firstOrNull != null
                ? CloudinaryThumbnail.of(hostel.photos.first.url)
                : null,
            createdAt: DateTime.now(),
          );
          await _activityRepo.create(activity);
        }
      } else {
        await _hostelRepo.update(hostel);
        if (status == ListingStatus.published && _editingHostel?.status != ListingStatus.published) {
           final activity = ActivityModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            ownerId: uid,
            type: 'listing_published',
            title: 'Listing Published',
            message: 'You published ${hostel.name} from a draft.',
            hostelId: hostel.id,
            hostelName: hostel.name,
            thumbnailUrl: hostel.photos.firstOrNull != null
                ? CloudinaryThumbnail.of(hostel.photos.first.url)
                : null,
            createdAt: DateTime.now(),
          );
          await _activityRepo.create(activity);
        }
      }

      if (status == ListingStatus.published) {
        Get.offNamed(Routes.ownerPublishSuccess);
      } else {
        Get.back();
        AppSnackbar.showGlobal(
          message: AppStrings.draftSavedMessage,
          type: SnackbarType.info,
        );
      }
    } on PartialUploadException catch (e) {
      // Some photos reached Cloudinary before the batch failed. No listing
      // document is written, so those assets are orphaned — record them for
      // the sweep job rather than losing the ids entirely (FIX-7.8).
      await _recordOrphanedUploads(uid, e.orphanedPublicIds);
      AppSnackbar.showGlobal(
        message: 'Failed to save listing: ${e.message}',
        type: SnackbarType.error,
      );
    } catch (e) {
      // Upstream services (StorageService/CloudinaryService) already throw
      // clean, user-facing Exception messages — strip the "Exception: "
      // toString() prefix rather than showing it, so the snackbar reads as
      // one plain sentence instead of a nested "Exception: Exception: ..."
      final rawMessage = e.toString();
      final cleanMessage = rawMessage.startsWith('Exception: ')
          ? rawMessage.substring('Exception: '.length)
          : rawMessage;
      AppSnackbar.showGlobal(
        message: 'Failed to save listing: $cleanMessage',
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
      uploadProgress.value = 0.0;
      uploadIndex.value = 0;
      uploadTotal.value = 0;
    }
  }

  /// Queues orphaned Cloudinary assets for server-side deletion (FIX-7.8).
  /// A signed destroy needs the API secret and can never run on the client,
  /// so the ids are parked in `cloudinary_orphans` for the sweep function in
  /// `functions/` to pick up. Best-effort: if this write itself fails the
  /// user still gets their upload error, which is the one that matters.
  Future<void> _recordOrphanedUploads(
    String uid,
    List<String> publicIds,
  ) async {
    if (publicIds.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('cloudinary_orphans').add({
        'publicIds': publicIds,
        'ownerId': uid,
        'reason': 'partial_upload',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.e('Could not record orphaned uploads $publicIds: $e');
    }
  }

  String _extractCity(String address) {
    if (address.isEmpty) return 'Hyderabad';
    final parts = address
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length > 1) {
      return parts.last;
    }
    final lower = address.toLowerCase();
    const commonCities = [
      'Hyderabad',
      'Jamshoro',
      'Karachi',
      'Lahore',
      'Islamabad',
      'Rawalpindi',
      'Faisalabad',
      'Multan',
      'Peshawar',
      'Quetta',
      'Sukkur',
      'Larkana',
      'Nawabshah',
    ];
    for (final c in commonCities) {
      if (lower.contains(c.toLowerCase())) return c;
    }
    final words = address.trim().split(RegExp(r'\s+'));
    if (words.isNotEmpty && words.last.length > 2) {
      return words.last;
    }
    return 'Hyderabad';
  }
}
