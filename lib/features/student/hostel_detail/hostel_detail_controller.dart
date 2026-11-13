import 'dart:async';
import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/hostel_model.dart';
import '../../../data/repositories/hostel_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/report_model.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/repositories/saved_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';

class HostelDetailController extends GetxController {
  final HostelRepository _hostelRepo = Get.find<HostelRepository>();
  final SavedRepository _savedRepo = Get.find<SavedRepository>();
  final SessionService _sessionService = Get.find<SessionService>();
  final ReportRepository _reportRepo = Get.find<ReportRepository>();
  
  late final HostelModel hostel;
  bool hasHostel = false;
  StreamSubscription? _savedSub;
  final isSaved = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is HostelModel) {
      hostel = args;
      hasHostel = true;
      // Fire and forget view increment
      _hostelRepo.incrementViews(hostel.id);
      _checkSavedStatus();
    } else {
      // Fallback or error handling
      Get.back();
    }
  }

  void _checkSavedStatus() {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid != null) {
      _savedSub = _savedRepo.streamSaved(uid).listen(
        (savedList) {
          isSaved.value = savedList.any((s) => s.hostelId == hostel.id);
        },
        onError: (Object e) => Logger.e('Detail: saved stream error: $e'),
      );
    }
  }

  @override
  void onClose() {
    _savedSub?.cancel();
    super.onClose();
  }

  /// Step 1 of reporting: pick a reason in a bottom sheet.
  void showReportSheet() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          color: AppColors.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(AppStrings.reportSheetTitle,
                    style: AppTextStyles.cardTitle),
              ),
              for (final reason in AppStrings.reportReasons)
                ListTile(
                  title: Text(reason, style: AppTextStyles.body),
                  onTap: () {
                    Get.back();
                    submitReport(reason);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitReport(String reason) async {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid == null) return;
    try {
      await _reportRepo.createReport(ReportModel(
        id: '${hostel.id}_$uid',
        hostelId: hostel.id,
        reportedBy: uid,
        reason: reason,
        details: '',
        status: 'open',
        createdAt: DateTime.now(),
      ));
      AppSnackbar.showGlobal(
          message: AppStrings.reportSubmitted, type: SnackbarType.success);
    } on FirebaseException catch (e) {
      // permission-denied here means this user's report already exists.
      AppSnackbar.showGlobal(
        message: e.code == 'permission-denied'
            ? AppStrings.reportAlreadySent
            : AppStrings.reportFailed,
        type: e.code == 'permission-denied'
            ? SnackbarType.info
            : SnackbarType.error,
      );
    } catch (_) {
      AppSnackbar.showGlobal(
          message: AppStrings.reportFailed, type: SnackbarType.error);
    }
  }

  void toggleSaved() {
    final uid = _sessionService.currentUser.value?.uid;
    if (uid == null) {
      AppSnackbar.showGlobal(
        message: 'Please sign in to save hostels',
        type: SnackbarType.info,
      );
      return;
    }

    final currentlySaved = isSaved.value;
    // Optimistic update
    isSaved.value = !currentlySaved;

    _savedRepo
        .toggleSave(uid, hostel.id, currentlySaved, hostel: hostel)
        .catchError((e) {
      // Rollback on failure
      isSaved.value = currentlySaved;
      AppSnackbar.showGlobal(
        message: 'Failed to update saved status',
        type: SnackbarType.error,
      );
    });
  }
}
