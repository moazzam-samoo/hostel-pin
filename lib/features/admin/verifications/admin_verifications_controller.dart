import '../../../../core/enums/listing_status.dart';
import 'dart:async';
import '../../../../core/utils/error_code.dart';
import '../../../../core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/config/edge_signer_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/hostel_model.dart';
import '../../../../data/models/verification_model.dart';
import '../../../../data/repositories/hostel_repository.dart';
import '../../../../data/repositories/verification_repository.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';

/// Phase 9 Block G — Verification Queue + Review. The queue (list) and the
/// per-submission Review detail are ONE screen/controller with an internal
/// two-state view (list <-> detail, driven by [selected]) rather than a
/// separate route — avoids duplicating the shared shell chrome for a
/// screen that's really just this tab's own drill-down state.
class AdminVerificationsController extends GetxController {
  final VerificationRepository _verificationRepo = Get.find<VerificationRepository>();
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final AuthService _auth = Get.find<AuthService>();

  final RxList<VerificationModel> all = <VerificationModel>[].obs;
  final RxBool isLoading = true.obs;

  // hostelId -> resolved HostelModel, for the queue table's Hostel Name/
  // City columns. VerificationModel doesn't denormalize either field, so
  // this is a one-off per-row fetch, cached — the same known-perf-tradeoff
  // shape Block E.3 already accepts for the Owners table's per-row listing
  // counts, not a new kind of shortcut for this screen.
  final RxMap<String, HostelModel> hostelCache = <String, HostelModel>{}.obs;

  // Detail/review state
  final Rxn<VerificationModel> selected = Rxn<VerificationModel>();
  final Rxn<HostelModel> selectedHostel = Rxn<HostelModel>();
  final RxBool isLoadingDetail = false.obs;
  final RxBool isSubmittingDecision = false.obs;
  // publicId -> resolved short-lived signed URL (Block G.3/G.4). Cleared on
  // every selection change — these are deliberately not persisted/cached
  // beyond one review session, since they're meant to be short-lived.
  final RxMap<String, String> resolvedDocUrls = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    _verificationRepo.streamAllForAdmin().listen((data) {
      all.assignAll(data);
      isLoading.value = false;
      _fetchMissingHostels(data);
      // Keep the open detail pane in sync if its doc changed underneath it
      // (e.g. another admin session reviewed it first).
      final currentId = selected.value?.uid;
      if (currentId != null) {
        final refreshed = data.where((v) => v.uid == currentId);
        if (refreshed.isNotEmpty) {
          selected.value = refreshed.first;
        }
      }
    }, onError: (Object e) {
      isLoading.value = false;
      Logger.e('Admin verifications load failed: $e');
      AppSnackbar.showGlobal(
          message: '${AppStrings.adminGenericLoadError} (${errorCode(e)})',
          type: SnackbarType.error);
    });
  }

  // ── Tabs (Block G.1) ────────────────────────────────────────────────
  // "Identity Pending" and "Hostel Pending" both resolve to the same
  // `pending` filter — see AppStrings' doc comment above
  // adminTabIdentityPending: this app's verification wizard produces ONE
  // combined submission (identity + hostel info together, submitted once),
  // so there is no real field distinguishing an identity-only pending
  // state from a hostel-only one. Not fabricated here.
  List<VerificationModel> get allTab => all;
  List<VerificationModel> get identityPendingTab => all.where((v) => v.status == 'pending').toList();
  List<VerificationModel> get hostelPendingTab => all.where((v) => v.status == 'pending').toList();
  List<VerificationModel> get changesRequiredTab => all.where((v) => v.status == 'changesRequested').toList();

  /// Every hostel this owner has sent for review (not just the one linked to
  /// the identity submission), live so a decision updates the list at once.
  final RxList<HostelModel> ownerHostels = <HostelModel>[].obs;
  StreamSubscription<List<HostelModel>>? _ownerHostelsSub;

  void _watchOwnerHostels(String ownerId) {
    _ownerHostelsSub?.cancel();
    ownerHostels.clear();
    _ownerHostelsSub = _hostelRepo.streamByOwner(ownerId).listen(
      (list) => ownerHostels.assignAll(
        list.where((h) => h.status != ListingStatus.draft),
      ),
      onError: (Object e) => Logger.e('Admin owner hostels load failed: $e'),
    );
  }

  Future<void> approveHostel(HostelModel hostel) async {
    try {
      await _hostelRepo.setStatus(hostel.id, ListingStatus.published);
      AppSnackbar.showGlobal(
        message: AppStrings.adminHostelApproved(hostel.name),
        type: SnackbarType.success,
      );
    } catch (e) {
      Logger.e('Admin approve hostel failed: $e');
      AppSnackbar.showGlobal(
          message: AppStrings.adminReviewActionError, type: SnackbarType.error);
    }
  }

  Future<void> rejectHostel(HostelModel hostel, String reason) async {
    if (reason.trim().isEmpty) return;
    try {
      await _hostelRepo.setStatus(
        hostel.id,
        ListingStatus.rejected,
        rejectionReason: reason.length > 500 ? reason.substring(0, 500) : reason,
      );
      AppSnackbar.showGlobal(
        message: AppStrings.adminHostelRejected(hostel.name),
        type: SnackbarType.success,
      );
    } catch (e) {
      Logger.e('Admin reject hostel failed: $e');
      AppSnackbar.showGlobal(
          message: AppStrings.adminReviewActionError, type: SnackbarType.error);
    }
  }

  @override
  void onClose() {
    _ownerHostelsSub?.cancel();
    super.onClose();
  }

  void _fetchMissingHostels(List<VerificationModel> submissions) {
    for (final s in submissions) {
      final hostelId = s.hostelId;
      if (hostelId != null && hostelId.isNotEmpty && !hostelCache.containsKey(hostelId)) {
        _hostelRepo.getById(hostelId).then((hostel) {
          if (hostel != null) hostelCache[hostelId] = hostel;
        });
      }
    }
  }

  // ── Selection / document resolution ─────────────────────────────────
  Future<void> selectSubmission(VerificationModel submission) async {
    selected.value = submission;
    selectedHostel.value = null;
    _watchOwnerHostels(submission.uid);
    resolvedDocUrls.clear();
    isLoadingDetail.value = true;

    final hostelId = submission.hostelId;
    if (hostelId != null && hostelId.isNotEmpty) {
      selectedHostel.value = await _hostelRepo.getById(hostelId);
    }

    // Eagerly resolve every document this submission carries — CNIC front/
    // back, selfie, ownership proof — through the Cloudflare Worker
    // (Block G.3). These are Cloudinary `type: authenticated` public_ids,
    // never renderable as bare URLs.
    final ids = <String>[
      submission.identityDocuments['cnicFrontUrl'] as String? ?? '',
      submission.identityDocuments['selfieUrl'] as String? ?? '',
      submission.identityDocuments['cnicBackUrl'] as String? ?? '',
      submission.ownershipDocumentUrl ?? '',
    ].where((id) => id.isNotEmpty).toSet();

    await Future.wait(ids.map(_resolveDocUrl));
    isLoadingDetail.value = false;
  }

  void clearSelection() {
    _ownerHostelsSub?.cancel();
    ownerHostels.clear();
    selected.value = null;
    selectedHostel.value = null;
    resolvedDocUrls.clear();
  }

  Future<void> _resolveDocUrl(String publicId) async {
    if (resolvedDocUrls.containsKey(publicId)) return;
    try {
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) return;

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ));
      final response = await dio.post(
        '${EdgeSignerConfig.baseUrl}/document-url',
        data: {'publicId': publicId},
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      final url = (response.data as Map<String, dynamic>)['url'] as String?;
      if (url != null) {
        resolvedDocUrls[publicId] = url;
      }
    } catch (_) {
      // Left unresolved — the view renders a "could not load" state for
      // this specific document rather than failing the whole review pane.
    }
  }

  // ── Decisions (Block G.5/G.6/G.7) ───────────────────────────────────
  Future<void> approve() async {
    final submission = selected.value;
    if (submission == null) return;
    final adminId = _auth.currentUser?.uid;
    if (adminId == null) return;

    isSubmittingDecision.value = true;
    try {
      await _verificationRepo.approveSubmission(
        verificationId: submission.uid,
        userId: submission.uid,
        adminId: adminId,
        hostelId: submission.hostelId,
      );
      AppSnackbar.showGlobal(message: AppStrings.adminSubmissionApproved, type: SnackbarType.success);
      clearSelection();
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminReviewActionError, type: SnackbarType.error);
    } finally {
      isSubmittingDecision.value = false;
    }
  }

  Future<void> reject(String reason) async {
    final submission = selected.value;
    if (submission == null) return;
    final adminId = _auth.currentUser?.uid;
    if (adminId == null) return;

    isSubmittingDecision.value = true;
    try {
      await _verificationRepo.rejectSubmission(
        verificationId: submission.uid,
        userId: submission.uid,
        adminId: adminId,
        reason: reason,
      );
      AppSnackbar.showGlobal(message: AppStrings.adminSubmissionRejected, type: SnackbarType.success);
      clearSelection();
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminReviewActionError, type: SnackbarType.error);
    } finally {
      isSubmittingDecision.value = false;
    }
  }

  Future<void> requestChanges(String reason) async {
    final submission = selected.value;
    if (submission == null) return;
    final adminId = _auth.currentUser?.uid;
    if (adminId == null) return;

    isSubmittingDecision.value = true;
    try {
      await _verificationRepo.requestChanges(
        verificationId: submission.uid,
        adminId: adminId,
        reason: reason,
      );
      AppSnackbar.showGlobal(message: AppStrings.adminChangesRequested, type: SnackbarType.success);
      clearSelection();
    } catch (e) {
      AppSnackbar.showGlobal(message: AppStrings.adminReviewActionError, type: SnackbarType.error);
    } finally {
      isSubmittingDecision.value = false;
    }
  }
}
