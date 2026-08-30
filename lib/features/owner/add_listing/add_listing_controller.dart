import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show setEquals, listEquals;
import 'package:flutter/services.dart' show PlatformException;
import 'package:get/get.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/models/upload_result_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/cloudinary_service.dart';
import 'widgets/location_source_sheet.dart';
import '../verification/widgets/image_source_sheet.dart';
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
import '../shell/owner_shell_controller.dart';
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
  final _cloudinaryService = Get.find<CloudinaryService>();

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

  // Property ownership document (the gap this feature fills — see
  // _requiresOwnershipDocument). Mirrors VerificationController's Step 4
  // pattern exactly: `ownershipDocPath` holds a local file pending upload,
  // `ownershipDocUploaded` is true once a public_id is persisted, and the
  // private `_ownershipId` string holds that public_id (a resumed
  // edit-mode document survives even after `ownershipDocPath` is cleared).
  final RxString ownershipDocPath = ''.obs;
  final RxBool ownershipDocUploaded = false.obs;
  String _ownershipId = '';

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
    ever(ownershipDocPath, (_) => update());
    ever(ownershipDocUploaded, (_) => update());
  }

  /// Whether this publish needs a fresh property-ownership document before
  /// it can go through. Scoped identically to publishListing()'s
  /// `wasAlreadyPublished` check below (NOT bare `!isEditMode`): a listing
  /// that was already live before this feature shipped can keep being
  /// edited/published without ever adding one — requiring it retroactively
  /// would trap existing owners' pre-existing listings, the same reasoning
  /// 2.A already established for the pending-review gate itself. A
  /// draft/rejected listing being edited and published for the first time
  /// (isEditMode true, but never actually published) is a genuinely new
  /// go-live exactly like a from-scratch create, so it still needs one.
  bool get _requiresOwnershipDocument =>
      _editingHostel?.status != ListingStatus.published;

  bool get _hasOwnershipDocument =>
      ownershipDocPath.value.isNotEmpty || ownershipDocUploaded.value;

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
        photos.length <= 10 &&
        (!_requiresOwnershipDocument || _hasOwnershipDocument);
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
        !listEquals(photos.toList(), _initialPhotos) ||
        // _populateForm never sets a local path (only the uploaded flag from
        // an existing hostel's already-persisted document), so any non-empty
        // path here is always a fresh, unsaved pick.
        ownershipDocPath.value.isNotEmpty;
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
    _ownershipId = hostel.ownershipDocumentId ?? '';
    ownershipDocUploaded.value = _ownershipId.isNotEmpty;
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

  /// Property ownership document picker — mirrors
  /// VerificationController.captureDocumentImage/`_pickImage` exactly
  /// (camera-or-gallery via the shared showImageSourceSheet(), never
  /// camera-only), including its PlatformException/permission handling.
  /// Duplicated rather than shared because these two controllers
  /// deliberately don't share a base class (see this feature's
  /// VerificationController's own header comment on that decision) — save
  /// timing genuinely diverges elsewhere between them.
  Future<void> pickOwnershipDocument() async {
    final source = await showImageSourceSheet();
    if (source == null) return;
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Compress slightly
      );
      if (image != null) {
        ownershipDocPath.value = image.path;
        ownershipDocUploaded.value = false; // a fresh pick supersedes any prior upload
      }
    } on PlatformException catch (e) {
      Logger.e('Image picker permission error: $e');
      final code = e.code.toLowerCase();
      final message = (e.message ?? '').toLowerCase();
      if (code.contains('denied') || code.contains('permission') || message.contains('permission')) {
        await _showCameraPermissionRationale();
      } else {
        AppSnackbar.showGlobal(
          message: AppStrings.cameraErrorGenericMessage,
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      Logger.e('Error picking ownership document: $e');
      AppSnackbar.showGlobal(
        message: AppStrings.cameraErrorGenericMessage,
        type: SnackbarType.error,
      );
    }
  }

  /// Mirrors VerificationController._showCameraPermissionRationale, which
  /// itself mirrors MapController._showLocationRationale's pattern — a
  /// plain explanatory dialog, not a raw OS permission crash or a silent
  /// failure.
  Future<void> _showCameraPermissionRationale() {
    return Get.dialog<void>(
      AlertDialog(
        title: const Text(AppStrings.cameraPermissionTitle),
        content: const Text(AppStrings.cameraPermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.okButton),
          ),
        ],
      ),
    );
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
    if (_requiresOwnershipDocument && !_hasOwnershipDocument) {
      AppSnackbar.showGlobal(
        message: AppStrings.errorNoOwnershipDocument,
        type: SnackbarType.error,
      );
      return;
    }
    // Every brand-new listing now requires admin approval before it's
    // publicly visible (matches what the verification wizard's step 3
    // already does for an owner's first hostel — see VerificationController.
    // _completeHostelInfoStep) — write `pending`, not `published`, directly.
    //
    // Scoping decision: gated on whether this hostel was ALREADY published
    // before, not on isEditMode. Editing an already-published (live)
    // listing keeps writing `published` directly — an edit of a listing
    // that's already live stays live; re-review-on-every-edit is a
    // separate, bigger product decision nobody has made. But editing a
    // DRAFT (or rejected) listing and hitting Publish for the first time is
    // still a genuinely new go-live, so it must go through the same pending
    // gate as a from-scratch create — `isEditMode` alone would wrongly let
    // an owner dodge review by saving a draft first and then "editing" it
    // straight to published. This reuses the exact same
    // already-published-before check `_saveListing`'s activity-log branch
    // below already makes (line ~424), rather than adding a second,
    // differently-scoped seam.
    final wasAlreadyPublished = _editingHostel?.status == ListingStatus.published;
    final targetStatus = wasAlreadyPublished ? ListingStatus.published : ListingStatus.pending;
    _saveListing(targetStatus);
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

      // 2. Upload the ownership document, if a new local file was picked.
      // Same "upload documents, then write the Firestore doc" ordering as
      // the photo batch just above and as
      // VerificationController._completeDocumentsStep's identical
      // upload-on-submit (not upload-on-pick) timing. A resumed/edit-mode
      // document that already carries a public_id (ownershipDocUploaded) is
      // left untouched, never re-uploaded.
      if (ownershipDocPath.value.isNotEmpty && !ownershipDocUploaded.value) {
        _ownershipId = await _cloudinaryService.uploadSignedDocument(
          File(ownershipDocPath.value),
          uid,
          'ownership',
        );
        ownershipDocUploaded.value = true;
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
        ownershipDocumentId: _ownershipId.isNotEmpty ? _ownershipId : null,
      );

      if (_editingHostel == null) {
        await _hostelRepo.create(hostel);
        // 2.A: a new create now writes `pending`, never `published`, directly
        // (see publishListing) — log the submission-for-review as its own
        // activity type rather than silently dropping the entry that used
        // to fire here for every new publish.
        if (status == ListingStatus.pending) {
          final activity = ActivityModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            ownerId: uid,
            type: 'listing_submitted',
            title: AppStrings.listingSubmittedActivityTitle,
            message: AppStrings.listingSubmittedActivityMessage(hostel.name),
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
        } else if (status == ListingStatus.pending && _editingHostel?.status != ListingStatus.pending) {
          // 2.A: editing a draft (or a rejected listing) and hitting
          // Publish for the first time is a genuinely new go-live, so
          // publishListing() routes it through `pending` here too, not
          // just on a from-scratch create — see that method's scoping note.
          final activity = ActivityModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            ownerId: uid,
            type: 'listing_submitted',
            title: AppStrings.listingSubmittedActivityTitle,
            message: AppStrings.listingSubmittedActivityMessage(hostel.name),
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

      if (status == ListingStatus.draft) {
        if (_editingHostel == null && Get.isRegistered<OwnerShellController>()) {
          Get.find<OwnerShellController>().onTabSelected(3); // Switch to Listings tab
          _resetForm();
        } else {
          Get.back();
        }
        AppSnackbar.showGlobal(
          message: AppStrings.draftSavedMessage,
          type: SnackbarType.info,
        );
      } else {
        // `pending` (new listing, awaiting review — 2.A) and `published`
        // (an edit that publishes directly) both land on the same success
        // screen; it reads its copy from `status` (see PublishSuccessView)
        // so a submission-for-review doesn't claim to already be live.
        if (_editingHostel == null && Get.isRegistered<OwnerShellController>()) {
          Get.toNamed(Routes.ownerPublishSuccess, arguments: status);
        } else {
          Get.offNamed(Routes.ownerPublishSuccess, arguments: status);
        }
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

  void _resetForm() {
    nameController.clear();
    addressController.clear();
    descriptionController.clear();
    priceController.clear();
    roomsController.clear();
    phoneController.clear();
    whatsappController.clear();
    selectedAmenities.clear();
    photos.clear();
    availability.value = AvailabilityStatus.available;
    sameAsPhone.value = false;
    hasPickedLocation.value = false;
    resolvedCity.value = '';
    ownershipDocPath.value = '';
    ownershipDocUploaded.value = false;
    _ownershipId = '';
    _editingHostel = null;

    _initialName = '';
    _initialAddress = '';
    _initialDescription = '';
    _initialPrice = '';
    _initialRooms = '';
    _initialPhone = '';
    _initialWhatsapp = '';
    _initialAmenities = {};
    _initialPhotos = [];
  }
}
