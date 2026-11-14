import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/listing_status.dart';
import '../../../core/enums/verification_status.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import '../../../data/repositories/verification_repository.dart';
import '../../../data/services/session_service.dart';
import 'owner_add_access.dart';

class OwnerShellController extends GetxController {
  final currentIndex = 0.obs;
  late final PageController pageController;

  final SessionService _session = Get.find<SessionService>();
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final VerificationRepository _verificationRepo = Get.find<VerificationRepository>();

  /// Whether the Add tab may offer the real form (see [resolveOwnerAddAccess]).
  final Rx<OwnerAddAccess> addAccess = OwnerAddAccess.needsVerification.obs;

  StreamSubscription? _verificationSub;
  StreamSubscription? _hostelsSub;
  String? _subscribedUid;
  String? _verificationDocStatus;
  List<HostelModel> _hostels = const [];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
    // The user doc re-emits on every profile change: only resubscribe when
    // the signed-in uid changes, but always recompute (status may have changed).
    ever(_session.currentUser, (_) {
      _syncSubscriptions();
      _recompute();
    });
    _syncSubscriptions();
    _recompute();
  }

  void _syncSubscriptions() {
    final uid = _session.currentUser.value?.uid;
    if (uid == _subscribedUid) return;
    _subscribedUid = uid;
    _verificationSub?.cancel();
    _hostelsSub?.cancel();
    _verificationDocStatus = null;
    _hostels = const [];
    if (uid == null) return;

    _verificationSub = _verificationRepo.streamVerification(uid).listen((v) {
      _verificationDocStatus = v?.status;
      _recompute();
    }, onError: (Object e) => Logger.e('Owner shell verification stream: $e'));

    _hostelsSub = _hostelRepo.streamByOwner(uid).listen((list) {
      _hostels = list;
      _recompute();
    }, onError: (Object e) => Logger.e('Owner shell hostels stream: $e'));
  }

  void _recompute() {
    final status = _session.currentUser.value?.verificationStatus ??
        VerificationStatus.unverified;
    addAccess.value = resolveOwnerAddAccess(
      userStatus: status,
      verificationDocStatus: _verificationDocStatus,
      hostels: _hostels,
    );
  }

  /// Hostels of this owner currently waiting for review.
  int get hostelsInReview =>
      _hostels.where((h) => h.status == ListingStatus.pending).length;

  void onTabSelected(int index) {
    currentIndex.value = index;
    if (pageController.hasClients && pageController.page?.round() != index) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    _verificationSub?.cancel();
    _hostelsSub?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
