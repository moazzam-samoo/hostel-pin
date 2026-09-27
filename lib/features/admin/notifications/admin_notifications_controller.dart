import 'package:get/get.dart';
import '../../../../data/repositories/verification_repository.dart';
import '../../../../data/repositories/report_repository.dart';
import '../../../../data/models/admin_notification_model.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class AdminNotificationsController extends GetxController {
  final VerificationRepository _verificationRepo = Get.find<VerificationRepository>();
  // Registered app-wide in InitialBinding (permanent: true) — Get.find, not
  // Get.put, so this doesn't create a second, divergent ReportRepository
  // instance every time this controller is constructed.
  final ReportRepository _reportRepo = Get.find<ReportRepository>();

  final RxList<AdminNotificationModel> notifications = <AdminNotificationModel>[].obs;
  final RxSet<String> readNotificationIds = <String>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  void _subscribe() {
    CombineLatestStream.combine2(
      _verificationRepo.streamPendingVerifications(),
      _reportRepo.streamOpenReports(),
      (verifications, reports) {
        final List<AdminNotificationModel> combined = [];
        
        // Map verifications
        combined.addAll(verifications.map((v) => AdminNotificationModel(
          id: 'verif_${v.uid}',
          title: AppStrings.adminPendingVerificationNotifHeading,
          message: AppStrings.adminPendingVerificationNotifTitle(
            (v.personalInfo['fullName'] as String?) ?? '',
          ),
          type: AdminNotificationType.verification,
          isRead: false,
          createdAt: v.submittedAt ?? DateTime.now(),
        )));

        // Map reports
        combined.addAll(reports.map((r) => AdminNotificationModel(
          id: 'report_${r.id}',
          title: AppStrings.adminHostelReportedNotifHeading,
          message: AppStrings.adminReportReasonMessage(r.reason),
          type: AdminNotificationType.report,
          isRead: false,
          createdAt: r.createdAt,
        )));

        // Stub system notification (Block F.3) — this project has no
        // deployed scheduled Cloud Functions (Blaze-blocked everywhere
        // else too), so this is manually-seeded/decorative copy, not a
        // live feed.
        combined.add(AdminNotificationModel(
          id: 'sys_1',
          title: AppStrings.adminSystemNotifStubTitle,
          message: AppStrings.adminSystemNotifStubMessage,
          type: AdminNotificationType.system,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ));

        // Sort by date descending
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return combined;
      }
    ).listen((data) {
      notifications.assignAll(data);
      isLoading.value = false;
    }, onError: (e) {
      // Print the exception for debugging rules/index issues
      debugPrint('Failed to load notifications: $e');
      isLoading.value = false;
      AppSnackbar.showGlobal(message: AppStrings.adminNotificationLoadError, type: SnackbarType.error);
    });
  }

  void markAsRead(String id) {
    readNotificationIds.add(id);
  }

  void markAllAsRead() {
    readNotificationIds.addAll(notifications.map((n) => n.id));
  }

  void clearAll() {
    // Client-side synthesis (Block F.4/F.5) has no single owning document
    // to persist a real "cleared" state onto — this marks everything read
    // rather than actually deleting the underlying verification/report
    // records, which stay real data other screens still depend on.
    readNotificationIds.addAll(notifications.map((n) => n.id));
    AppSnackbar.showGlobal(message: AppStrings.adminAllNotificationsCleared, type: SnackbarType.info);
  }

  bool isRead(String id) => readNotificationIds.contains(id);

  List<AdminNotificationModel> get verificationNotifications => 
      notifications.where((n) => n.type == AdminNotificationType.verification).toList();
      
  List<AdminNotificationModel> get reportNotifications => 
      notifications.where((n) => n.type == AdminNotificationType.report).toList();
      
  List<AdminNotificationModel> get systemNotifications => 
      notifications.where((n) => n.type == AdminNotificationType.system).toList();
}
