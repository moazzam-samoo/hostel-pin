import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show setEquals, listEquals;
import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../core/enums/amenity.dart';
import '../../../core/enums/listing_status.dart';
import '../../../core/enums/availability_status.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
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
  final MockDataService _dataService = Get.find<MockDataService>();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final roomsController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();

  final selectedAmenities = <Amenity>{}.obs;
  final sameAsPhone = false.obs;
  final availability = AvailabilityStatus.available.obs;

  // For mock photos, just storing local file paths or URLs
  final photos = <String>[].obs;

  // Location
  final latitude = 25.3960.obs;
  final longitude = 68.3722.obs;
  final hasPickedLocation = false.obs;

  final ImagePicker _picker = ImagePicker();

  HostelModel? _editingHostel;
  bool get isEditMode => _editingHostel != null;

  // Snapshot of every field's initial value, captured once in onInit, used
  // by the unsaved-changes guard (PopScope + ConfirmDialog) on back nav.
  late final String _initialName;
  late final String _initialAddress;
  late final String _initialPrice;
  late final String _initialRooms;
  late final String _initialPhone;
  late final String _initialWhatsapp;
  late final Set<Amenity> _initialAmenities;
  late final List<String> _initialPhotos;

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
    for (final c in [nameController, addressController, priceController, roomsController, whatsappController]) {
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
        Validators.price(priceController.text) == null &&
        Validators.rooms(roomsController.text) == null &&
        Validators.phone(phoneController.text) == null &&
        Validators.phone(whatsappController.text) == null &&
        photos.length >= 5 &&
        photos.length <= 10;
  }

  /// Whether the form differs from its initial (edit-mode prefill, or
  /// blank-create) state — drives the unsaved-changes guard on back nav.
  bool get hasUnsavedChanges {
    return nameController.text != _initialName ||
        addressController.text != _initialAddress ||
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
    priceController.text = hostel.pricePerMonth.toString();
    roomsController.text = '1'; // Default as we don't have this in HostelModel
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
    priceController.dispose();
    roomsController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    super.onClose();
  }

  void toggleAvailability(bool isAvailable) {
    availability.value = isAvailable ? AvailabilityStatus.available : AvailabilityStatus.full;
  }

  void toggleAmenity(Amenity amenity) {
    if (selectedAmenities.contains(amenity)) {
      selectedAmenities.remove(amenity);
    } else {
      selectedAmenities.add(amenity);
    }
  }

  Future<void> pickLocation() async {
    final result = await Get.toNamed<LatLng>(
      Routes.ownerLocationPicker,
    );
    if (result != null) {
      latitude.value = result.latitude;
      longitude.value = result.longitude;
      hasPickedLocation.value = true;
    }
  }

  Future<void> pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      for (var image in selectedImages) {
        if (photos.length < 10) {
          photos.add(image.path);
        } else {
          AppSnackbar.showGlobal(message: AppStrings.errorMaxPhotos, type: SnackbarType.error);
          break;
        }
      }
    }
  }

  void saveAsDraft() {
    _saveListing(ListingStatus.draft);
  }

  void publishListing() {
    if (formKey.currentState?.validate() ?? false) {
      if (photos.length < 5) {
        AppSnackbar.showGlobal(message: AppStrings.errorMinPhotos, type: SnackbarType.error);
        return;
      }
      if (photos.length > 10) {
        AppSnackbar.showGlobal(message: AppStrings.errorMaxPhotos, type: SnackbarType.error);
        return;
      }
      _saveListing(ListingStatus.published);
    }
  }

  void _saveListing(ListingStatus status) {
    final uid = _dataService.currentUser.value?.uid ?? 'mock_owner_id';
    final ownerName = _dataService.currentUser.value?.displayName ?? 'Anonymous';
    
    final hostel = HostelModel(
      id: _editingHostel?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: uid,
      ownerName: ownerName,
      name: nameController.text.trim(),
      description: 'Hostel Description', // Placeholder
      fullAddress: addressController.text.trim(),
      city: 'Unknown City', // Placeholder
      pricePerMonth: double.tryParse(priceController.text) ?? 0.0,
      rating: _editingHostel?.rating ?? 0.0,
      reviewCount: _editingHostel?.reviewCount ?? 0,
      viewCount: _editingHostel?.viewCount ?? 0,
      contactPhone: phoneController.text.trim(),
      contactWhatsapp: whatsappController.text.trim(),
      latitude: latitude.value,
      longitude: longitude.value,
      amenities: selectedAmenities.toSet(),
      photos: photos.toList(),
      availability: availability.value,
      status: status,
    );

    _dataService.upsertListing(hostel);

    if (status == ListingStatus.published) {
      Get.offNamed(Routes.ownerPublishSuccess);
    } else {
      Get.back();
      AppSnackbar.showGlobal(
        message: AppStrings.draftSavedMessage,
        type: SnackbarType.info,
      );
    }
  }
}
