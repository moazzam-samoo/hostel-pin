import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/verification_step.dart';
import '../../../core/enums/amenity.dart';
import '../../../core/enums/availability_status.dart';
import '../../../core/enums/listing_status.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/verification_model.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/models/upload_result_model.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/location_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/cards/verification_task_card.dart';
import '../add_listing/widgets/location_source_sheet.dart';
import 'widgets/image_source_sheet.dart';
import '../../../core/utils/logger.dart';

/// Phase 8 wizard controller. Block D.3's recorded decision: this does NOT
/// share a base class with AddListingController — save behavior genuinely
/// diverges (Firestore-persisted per-step drafts tied to a
/// verifications/{uid} doc + a `hostels` doc written as `status: pending`,
/// vs AddListingController's immediate draft/published write). It DOES
/// reuse AddListingController's already-generalized *view*-level building
/// blocks (ValidatedTextField, AmenitySelector, ImageUploadSection, MapPanel,
/// showLocationSourceSheet) — see step3_hostel_info.dart.
class VerificationController extends GetxController {
  final VerificationRepository _verificationRepo = Get.find<VerificationRepository>();
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final AuthService _authService = Get.find<AuthService>();
  final SessionService _sessionService = Get.find<SessionService>();
  final CloudinaryService _cloudinaryService = Get.find<CloudinaryService>();
  final StorageService _storageService = Get.find<StorageService>();
  final LocationService _locationService = Get.find<LocationService>();
  final _imagePicker = ImagePicker();

  final Rx<VerificationStep> currentStep = VerificationStep.personalInfo.obs;
  final RxBool isLoading = false.obs;

  /// Latest known server state, kept live for two reasons: (1) so
  /// `_buildCurrentModel` never clobbers admin-only fields
  /// (reviewedAt/reviewedBy/rejectionReason) it doesn't itself own, and (2)
  /// so a resubmit after Phase 9 exists can't accidentally regress
  /// `status` from 'pending' back to 'draft' via an early-step autosave.
  final Rx<VerificationModel?> verificationData = Rx<VerificationModel?>(null);

  /// Restoring form-field values from a resumed draft happens exactly once
  /// (D.9) — a live listener re-firing on every write this controller makes
  /// itself must not stomp whatever the owner is actively typing on a later
  /// step.
  bool _hydrated = false;
  StreamSubscription<VerificationModel?>? _verificationSub;

  /// Set once step 3 creates the `hostels` doc, or restored from a resumed
  /// draft's `hostelId`. Distinguishes "create" from "update" on repeat
  /// visits to step 3.
  String? _hostelId;

  // Step 1: Personal Info
  final personalInfoFormKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final guardianNameController = TextEditingController();
  final cnicController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();

  // Step 2: Identity Documents. `*Path` holds a local file pending upload;
  // `*Uploaded` is true once a public_id is persisted (survives a session
  // even after `*Path` is cleared, and after an app restart even though
  // the local temp file itself would not survive one).
  final RxString cnicFrontPath = ''.obs;
  final RxString cnicBackPath = ''.obs;
  final RxString selfiePath = ''.obs;
  final RxBool cnicFrontUploaded = false.obs;
  final RxBool cnicBackUploaded = false.obs;
  final RxBool selfieUploaded = false.obs;
  final RxBool isSelfieMode = false.obs;
  String _cnicFrontId = '';
  String _cnicBackId = '';
  String _selfieId = '';

  // Step 3: Hostel Info — the owner's real first listing (D.2/D.6). Every
  // field AddListingController collects, plus totalBeds (Phase 8, new) and
  // photos (D.2's recorded gap-fill — without these no hostel this wizard
  // creates could ever satisfy AddListingController.isValid's
  // photos.length >= 3 gate).
  final hostelInfoFormKey = GlobalKey<FormState>();
  final hostelNameController = TextEditingController();
  final hostelAddressController = TextEditingController();
  final hostelDescriptionController = TextEditingController();
  final hostelPriceController = TextEditingController();
  final hostelRoomsController = TextEditingController();
  final hostelBedsController = TextEditingController();
  final hostelPhoneController = TextEditingController();
  final hostelWhatsappController = TextEditingController();
  final selectedAmenities = <Amenity>{}.obs;
  final availability = AvailabilityStatus.available.obs;
  final photos = <UploadResultModel>[].obs;
  final latitude = 25.3960.obs;
  final longitude = 68.3722.obs;
  final hasPickedLocation = false.obs;
  final resolvedCity = ''.obs;

  // Step 4: Hostel Documents
  final RxString ownershipDocPath = ''.obs;
  final RxBool ownershipDocUploaded = false.obs;
  String _ownershipId = '';

  // Step 5: Review
  final RxBool policyAccepted = false.obs;

  // Task list status getters
  VerificationTaskStatus get personalInfoStatus {
    if (fullNameController.text.isNotEmpty) return VerificationTaskStatus.completed;
    return VerificationTaskStatus.notCompleted;
  }

  VerificationTaskStatus get identityStatus {
    if (cnicFrontUploaded.value && cnicBackUploaded.value && selfieUploaded.value) {
      return VerificationTaskStatus.completed;
    }
    return VerificationTaskStatus.notCompleted;
  }

  VerificationTaskStatus get hostelInfoStatus {
    if (_hostelId != null && _hostelId!.isNotEmpty) return VerificationTaskStatus.completed;
    return VerificationTaskStatus.notCompleted;
  }

  VerificationTaskStatus get documentsStatus {
    if (ownershipDocUploaded.value) return VerificationTaskStatus.completed;
    return VerificationTaskStatus.notCompleted;
  }

  VerificationTaskStatus get reviewStatus {
    if (verificationData.value?.status == 'pending') return VerificationTaskStatus.pending;
    if (verificationData.value?.status == 'verified' || verificationData.value?.status == 'approved') {
      return VerificationTaskStatus.completed;
    }
    return VerificationTaskStatus.notCompleted;
  }

  int get completedStepsCount {
    int count = 0;
    if (personalInfoStatus == VerificationTaskStatus.completed) count++;
    if (identityStatus == VerificationTaskStatus.completed) count++;
    if (hostelInfoStatus == VerificationTaskStatus.completed) count++;
    if (documentsStatus == VerificationTaskStatus.completed) count++;
    if (reviewStatus == VerificationTaskStatus.completed || reviewStatus == VerificationTaskStatus.pending) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    _loadVerificationData();
  }

  @override
  void onClose() {
    _verificationSub?.cancel();
    fullNameController.dispose();
    guardianNameController.dispose();
    cnicController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    hostelNameController.dispose();
    hostelAddressController.dispose();
    hostelDescriptionController.dispose();
    hostelPriceController.dispose();
    hostelRoomsController.dispose();
    hostelBedsController.dispose();
    hostelPhoneController.dispose();
    hostelWhatsappController.dispose();
    super.onClose();
  }

  void _loadVerificationData() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    _verificationSub = _verificationRepo.streamVerification(uid).listen((data) {
      verificationData.value = data;
      if (!_hydrated) {
        _hydrated = true;
        if (data != null) _hydrate(data);
      }
    }, onError: (Object e) {
      Logger.e('Verification stream error: $e');
    });
  }

  void _hydrate(VerificationModel data) {
    if (data.personalInfo.isNotEmpty) {
      fullNameController.text = data.personalInfo['fullName'] ?? '';
      guardianNameController.text = data.personalInfo['guardianName'] ?? '';
      cnicController.text = data.personalInfo['cnicNumber'] ?? '';
      dobController.text = data.personalInfo['dob'] ?? '';
      phoneController.text = data.personalInfo['phone'] ?? '';
      emailController.text = data.personalInfo['email'] ?? '';
      cityController.text = data.personalInfo['city'] ?? '';
    }

    _cnicFrontId = data.identityDocuments['cnicFrontUrl'] as String? ?? '';
    _cnicBackId = data.identityDocuments['cnicBackUrl'] as String? ?? '';
    _selfieId = data.identityDocuments['selfieUrl'] as String? ?? '';
    cnicFrontUploaded.value = _cnicFrontId.isNotEmpty;
    cnicBackUploaded.value = _cnicBackId.isNotEmpty;
    selfieUploaded.value = _selfieId.isNotEmpty;

    _ownershipId = data.ownershipDocumentUrl ?? '';
    ownershipDocUploaded.value = _ownershipId.isNotEmpty;

    _hostelId = data.hostelId;
    if (_hostelId != null && _hostelId!.isNotEmpty) {
      _hostelRepo.getById(_hostelId!).then((hostel) {
        if (hostel != null) _populateHostelFields(hostel);
      });
    }

    currentStep.value = _computeResumeStep(data);
  }

  /// D.9's concrete resumability mechanism: the furthest step whose data is
  /// actually persisted, not a separately-stored "current step" field (no
  /// such field exists in Appendix C's frozen `verifications/{uid}` schema).
  VerificationStep _computeResumeStep(VerificationModel data) {
    if ((data.ownershipDocumentUrl ?? '').isNotEmpty) {
      return VerificationStep.review;
    }
    if ((data.hostelId ?? '').isNotEmpty) {
      return VerificationStep.documents;
    }
    if (_cnicFrontId.isNotEmpty && _cnicBackId.isNotEmpty && _selfieId.isNotEmpty) {
      return VerificationStep.hostelInfo;
    }
    if (data.personalInfo.isNotEmpty) {
      return VerificationStep.identity;
    }
    return VerificationStep.personalInfo;
  }

  void _populateHostelFields(HostelModel hostel) {
    hostelNameController.text = hostel.name;
    hostelAddressController.text = hostel.fullAddress;
    hostelDescriptionController.text = hostel.description;
    hostelPriceController.text = hostel.pricePerMonth.toString();
    hostelRoomsController.text = hostel.totalRooms.toString();
    hostelBedsController.text = hostel.totalBeds.toString();
    hostelPhoneController.text = hostel.contactPhone;
    hostelWhatsappController.text = hostel.contactWhatsapp;
    selectedAmenities.assignAll(hostel.amenities);
    photos.assignAll(hostel.photos);
    availability.value = hostel.availability;
    latitude.value = hostel.latitude;
    longitude.value = hostel.longitude;
    hasPickedLocation.value = true;
  }

  /// Builds the FULL accumulated draft, not just this step's delta.
  /// `VerificationRepository.updateVerification` writes via `set(...,
  /// merge:true)`, which replaces a whole top-level field (personalInfo/
  /// identityDocuments are plain maps) rather than deep-merging it — saving
  /// a partial model at every step would silently wipe fields an earlier
  /// step already persisted.
  VerificationModel _buildCurrentModel(
    String uid, {
    String? statusOverride,
    DateTime? submittedAt,
  }) {
    final current = verificationData.value;
    return VerificationModel(
      uid: uid,
      // Never regress an already-submitted draft back to 'draft' via a
      // later autosave (Block E.2's "write-once forward" transition rule).
      status: statusOverride ?? (current?.status == 'pending' ? 'pending' : 'draft'),
      personalInfo: {
        'fullName': fullNameController.text.trim(),
        'guardianName': guardianNameController.text.trim(),
        'cnicNumber': cnicController.text.trim(),
        'dob': dobController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'city': cityController.text.trim(),
      },
      identityDocuments: {
        if (_cnicFrontId.isNotEmpty) 'cnicFrontUrl': _cnicFrontId,
        if (_cnicBackId.isNotEmpty) 'cnicBackUrl': _cnicBackId,
        if (_selfieId.isNotEmpty) 'selfieUrl': _selfieId,
      },
      hostelId: _hostelId,
      ownershipDocumentUrl: _ownershipId.isNotEmpty ? _ownershipId : null,
      submittedAt: submittedAt ?? current?.submittedAt,
      reviewedAt: current?.reviewedAt,
      reviewedBy: current?.reviewedBy,
      rejectionReason: current?.rejectionReason,
    );
  }

  /// Each step's completion persists to Firestore (D.9) — not just an
  /// in-memory `currentStep` advance — so "Save and continue later"
  /// genuinely resumes after an app restart.
  Future<void> nextStep() async {
    switch (currentStep.value) {
      case VerificationStep.personalInfo:
        await _completePersonalInfoStep();
      case VerificationStep.identity:
        await _completeIdentityStep();
      case VerificationStep.hostelInfo:
        await _completeHostelInfoStep();
      case VerificationStep.documents:
        await _completeDocumentsStep();
      case VerificationStep.review:
        await submitVerification();
      case VerificationStep.submission:
        // Do nothing or navigate
        break;
    }
  }

  void previousStep() {
    if (currentStep.value == VerificationStep.identity) {
      currentStep.value = VerificationStep.personalInfo;
    } else if (currentStep.value == VerificationStep.hostelInfo) {
      currentStep.value = VerificationStep.identity;
    } else if (currentStep.value == VerificationStep.documents) {
      currentStep.value = VerificationStep.hostelInfo;
    } else if (currentStep.value == VerificationStep.review) {
      currentStep.value = VerificationStep.documents;
    }
  }

  /// Jumps directly to a step — used by the Review step's per-section
  /// "Edit" links (D.8). Does not skip validation on the way forward again;
  /// `nextStep` from wherever the owner lands still re-validates normally.
  void editStep(VerificationStep step) {
    currentStep.value = step;
  }

  Future<void> _completePersonalInfoStep() async {
    if (!personalInfoFormKey.currentState!.validate()) return;
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;
    try {
      await _verificationRepo.updateVerification(_buildCurrentModel(uid));
      currentStep.value = VerificationStep.identity;
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completeIdentityStep() async {
    final hasFront = cnicFrontPath.value.isNotEmpty || cnicFrontUploaded.value;
    final hasBack = cnicBackPath.value.isNotEmpty || cnicBackUploaded.value;
    final hasSelfie = selfiePath.value.isNotEmpty || selfieUploaded.value;
    if (!hasFront || !hasBack || !hasSelfie) {
      AppSnackbar.showGlobal(
        message: AppStrings.errorNoIdentityDocuments,
        type: SnackbarType.error,
      );
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;
    try {
      if (!cnicFrontUploaded.value) {
        _cnicFrontId = await _cloudinaryService.uploadSignedDocument(
          File(cnicFrontPath.value),
          uid,
          'cnic_front',
        );
        cnicFrontUploaded.value = true;
      }
      if (!cnicBackUploaded.value) {
        _cnicBackId = await _cloudinaryService.uploadSignedDocument(
          File(cnicBackPath.value),
          uid,
          'cnic_back',
        );
        cnicBackUploaded.value = true;
      }
      if (!selfieUploaded.value) {
        _selfieId = await _cloudinaryService.uploadSignedDocument(
          File(selfiePath.value),
          uid,
          'selfie',
        );
        selfieUploaded.value = true;
      }
      await _verificationRepo.updateVerification(_buildCurrentModel(uid));
      currentStep.value = VerificationStep.hostelInfo;
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completeHostelInfoStep() async {
    if (!hostelInfoFormKey.currentState!.validate()) return;
    if (photos.length < 3) {
      AppSnackbar.showGlobal(message: AppStrings.errorMinPhotos, type: SnackbarType.error);
      return;
    }
    if (photos.length > 10) {
      AppSnackbar.showGlobal(message: AppStrings.errorMaxPhotos, type: SnackbarType.error);
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final ownerName = _sessionService.currentUser.value?.displayName ?? '';

    isLoading.value = true;
    try {
      // Only locally-picked files (empty publicId) need uploading — a
      // resumed draft's already-uploaded photos carry one and are left
      // untouched, same batching pattern as AddListingController._saveListing.
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
        final results = await _storageService.uploadImages(pendingFiles, 'hostels');
        for (var i = 0; i < pendingIndices.length; i++) {
          uploadedPhotos[pendingIndices[i]] = results[i];
        }
        photos.assignAll(uploadedPhotos);
      }

      final geohash = _locationService.getGeohash(latitude.value, longitude.value);
      final city = resolvedCity.value.isNotEmpty
          ? resolvedCity.value
          : _fallbackCity(hostelAddressController.text.trim());

      final hostel = HostelModel(
        id: _hostelId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: uid,
        ownerName: ownerName,
        name: hostelNameController.text.trim(),
        description: hostelDescriptionController.text.trim(),
        fullAddress: hostelAddressController.text.trim(),
        city: city,
        pricePerMonth: double.tryParse(hostelPriceController.text) ?? 0.0,
        totalRooms: int.tryParse(hostelRoomsController.text) ?? 1,
        totalBeds: int.tryParse(hostelBedsController.text) ?? 1,
        contactPhone: hostelPhoneController.text.trim(),
        contactWhatsapp: hostelWhatsappController.text.trim(),
        latitude: latitude.value,
        longitude: longitude.value,
        amenities: selectedAmenities.toSet(),
        photos: uploadedPhotos,
        availability: availability.value,
        // The wizard's first real write of ListingStatus.pending — this
        // hostel goes live only once Phase 9's admin approval flips it,
        // same review gate every other new listing now goes through (2.A).
        status: ListingStatus.pending,
        location: GeoPoint(latitude.value, longitude.value),
        geohash: geohash,
        ownershipDocumentId: _ownershipId.isNotEmpty ? _ownershipId : null,
      );

      if (_hostelId == null) {
        await _hostelRepo.create(hostel);
        _hostelId = hostel.id;
      } else {
        await _hostelRepo.update(hostel);
      }

      await _verificationRepo.updateVerification(_buildCurrentModel(uid));
      currentStep.value = VerificationStep.documents;
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completeDocumentsStep() async {
    final hasDoc = ownershipDocPath.value.isNotEmpty || ownershipDocUploaded.value;
    if (!hasDoc) {
      AppSnackbar.showGlobal(
        message: AppStrings.errorNoOwnershipDocument,
        type: SnackbarType.error,
      );
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;
    try {
      if (!ownershipDocUploaded.value) {
        _ownershipId = await _cloudinaryService.uploadSignedDocument(
          File(ownershipDocPath.value),
          uid,
          'ownership',
        );
        ownershipDocUploaded.value = true;
      }
      // Back-fill the proof onto the hostel this wizard created in step 3.
      // Without it, opening that listing later in Add Listing found no
      // ownership document and forced the owner to upload one again.
      final hostelId = _hostelId;
      if (hostelId != null && hostelId.isNotEmpty && _ownershipId.isNotEmpty) {
        final hostel = await _hostelRepo.getById(hostelId);
        if (hostel != null && hostel.ownershipDocumentId != _ownershipId) {
          await _hostelRepo.update(
            hostel.copyWith(ownershipDocumentId: _ownershipId),
          );
        }
      }
      await _verificationRepo.updateVerification(_buildCurrentModel(uid));
      currentStep.value = VerificationStep.review;
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitVerification() async {
    if (!policyAccepted.value) {
      AppSnackbar.showGlobal(
        message: AppStrings.errorAcceptPolicy,
        type: SnackbarType.error,
      );
      return;
    }

    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;
    try {
      await _verificationRepo.updateVerification(
        _buildCurrentModel(uid, statusOverride: 'pending', submittedAt: DateTime.now()),
      );
      AppSnackbar.showGlobal(
        message: AppStrings.verificationSubmittedMessage,
        type: SnackbarType.success,
      );
      // Not a fake client-side auto-verify (§8's D1 decision) — status is
      // 'pending' here, and stays that way until Phase 9's admin action
      // (which does not exist yet) flips it. No path in this file ever
      // writes 'approved'/'verified'.
      currentStep.value = VerificationStep.submission;
    } catch (e) {
      _showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Step 2 / 4: image capture ────────────────────────────────────────

  /// Block A.7 decision: the selfie stays camera-only — a liveness check
  /// needs a live capture, a gallery image could be an old or borrowed
  /// photo standing in for one. This is the one picker call site in the
  /// app that intentionally offers no gallery fallback at all.
  Future<void> captureImage(RxString targetPath, RxBool uploadedFlag) async {
    await _pickImage(ImageSource.camera, targetPath, uploadedFlag);
  }

  /// CNIC front/back and the ownership document, unlike the selfie above,
  /// are very often an existing scan/photo the owner already has — forcing
  /// a fresh camera capture for those was a real usability gap, not a
  /// security requirement the way the selfie's liveness check is. Offers
  /// a source-choice sheet (camera vs. gallery) instead of going straight
  /// to the camera.
  Future<void> captureDocumentImage(RxString targetPath, RxBool uploadedFlag) async {
    final source = await showImageSourceSheet();
    if (source == null) return;
    await _pickImage(source, targetPath, uploadedFlag);
  }

  Future<void> _pickImage(
    ImageSource source,
    RxString targetPath,
    RxBool uploadedFlag,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Compress slightly
      );
      if (image != null) {
        targetPath.value = image.path;
        uploadedFlag.value = false; // a fresh pick supersedes any prior upload
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
      Logger.e('Error picking image: $e');
      AppSnackbar.showGlobal(
        message: AppStrings.cameraErrorGenericMessage,
        type: SnackbarType.error,
      );
    }
  }

  void removeCapturedImage(RxString path, RxBool uploadedFlag) {
    path.value = '';
    uploadedFlag.value = false;
  }

  /// Block A.7 — camera-permission-denied fallback, in the same
  /// pre-permission-rationale shape MapController._showLocationRationale
  /// already established for location (a plain explanatory dialog, not a
  /// raw OS permission crash or silent failure).
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

  // ── Step 3: hostel info field helpers ───────────────────────────────

  void toggleAmenity(Amenity amenity) {
    if (selectedAmenities.contains(amenity)) {
      selectedAmenities.remove(amenity);
    } else {
      selectedAmenities.add(amenity);
    }
  }

  void toggleAvailability(bool isAvailable) {
    availability.value = isAvailable ? AvailabilityStatus.available : AvailabilityStatus.full;
  }

  Future<void> pickHostelPhotos() async {
    final List<XFile> selectedImages = await _imagePicker.pickMultiImage();
    if (selectedImages.isEmpty) return;
    for (final image in selectedImages) {
      if (photos.length < 10) {
        photos.add(UploadResultModel(url: image.path, publicId: ''));
      } else {
        AppSnackbar.showGlobal(message: AppStrings.errorMaxPhotos, type: SnackbarType.error);
        break;
      }
    }
  }

  void removeHostelPhoto(UploadResultModel photo) => photos.remove(photo);

  /// Owners submitting identity verification must be adults — bounds the
  /// picker to a plausible 18-100 year range instead of a free-text field
  /// that happily accepted garbage like "128544" as a date.
  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (picked != null) {
      // Matches AppStrings.dobHint's DD-MM-YYYY format exactly.
      dobController.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  Future<void> pickLocation() async {
    final source = await showLocationSourceSheet();
    switch (source) {
      case LocationSource.currentLocation:
        await _useCurrentLocation();
      case LocationSource.chooseOnMap:
        await _chooseOnMap();
      case null:
        break;
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

  Future<void> _resolvePinnedPlace() async {
    final place = await _locationService.resolvePlace(latitude.value, longitude.value);
    if (place == null) return;
    if (place.city != null && place.city!.isNotEmpty) {
      resolvedCity.value = place.city!;
    }
    if (hostelAddressController.text.trim().isEmpty && place.formattedAddress != null) {
      hostelAddressController.text = place.formattedAddress!;
    }
  }

  Future<void> _chooseOnMap() async {
    final result = await Get.toNamed(
      Routes.ownerLocationPicker,
      arguments: hasPickedLocation.value ? LatLng(latitude.value, longitude.value) : null,
    );
    if (result is LatLng) {
      latitude.value = result.latitude;
      longitude.value = result.longitude;
      hasPickedLocation.value = true;
      await _resolvePinnedPlace();
    }
  }

  String _fallbackCity(String address) {
    if (address.isEmpty) return AppStrings.defaultCityFallback;
    final parts = address.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.last : AppStrings.defaultCityFallback;
  }

  void _showError(Object e) {
    Logger.e('Verification wizard error: $e');
    final raw = e.toString();
    final clean = raw.startsWith('Exception: ') ? raw.substring('Exception: '.length) : raw;
    AppSnackbar.showGlobal(message: clean, type: SnackbarType.error);
  }
}
