import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_notifications_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/admin_notification_model.dart';

class AdminNotificationsView extends GetView<AdminNotificationsController> {
  const AdminNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final actionsRow = Row(
      children: [
        Obx(() => controller.notifications.any((n) => !controller.isRead(n.id))
            ? TextButton.icon(
                onPressed: controller.markAllAsRead,
                icon: const Icon(Icons.done_all, color: AppColors.primary),
                label: Text(
                  AppStrings.adminMarkAllAsRead,
                  style: AppTextStyles.body.copyWith(color: AppColors.primary),
                ),
              )
            : const SizedBox.shrink()),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: controller.clearAll,
          icon: const Icon(Icons.clear_all, color: AppColors.error),
          label: Text(
            AppStrings.adminClearAll,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );

    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Responsive.isDesktop(context)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.adminNotificationsTitle, style: AppTextStyles.screenTitle),
                      actionsRow,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.adminNotificationsTitle, style: AppTextStyles.screenTitle),
                      const SizedBox(height: 8),
                      actionsRow,
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: AppTextStyles.body,
              unselectedLabelStyle: AppTextStyles.body,
              tabs: const [
                Tab(text: AppStrings.adminTabAll),
                Tab(text: AppStrings.adminTabVerifications),
                Tab(text: AppStrings.adminTabReports),
                Tab(text: AppStrings.adminTabSystem),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNotificationList(context, () => controller.notifications),
                _buildNotificationList(context, () => controller.verificationNotifications),
                _buildNotificationList(context, () => controller.reportNotifications),
                _buildNotificationList(context, () => controller.systemNotifications),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, List<dynamic> Function() getList) {
    return Obx(() {
      final list = getList();
      if (controller.isLoading.value && list.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      if (list.isEmpty) {
        return Center(
          child: Text(
            AppStrings.adminNoNotifications,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        itemCount: list.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final notification = list[index];
          final isRead = controller.isRead(notification.id);
          IconData icon = Icons.info;
          Color iconColor = AppColors.textSecondary;

          switch (notification.type) {
            case AdminNotificationType.verification:
              icon = Icons.verified_user;
              iconColor = AppColors.primary;
              break;
            case AdminNotificationType.report:
              icon = Icons.report_problem;
              iconColor = AppColors.error;
              break;
            case AdminNotificationType.system:
              break;
          }

          return ListTile(
            contentPadding: const EdgeInsets.all(16),
            tileColor: isRead ? Colors.white : AppColors.primary.withAlpha(10),
            leading: CircleAvatar(
              backgroundColor: iconColor.withAlpha(25),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            title: Text(
              notification.title,
              style: AppTextStyles.body.copyWith(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.message, style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            trailing: !isRead
                ? IconButton(
                    icon: const Icon(Icons.circle, color: AppColors.primary, size: 12),
                    onPressed: () => controller.markAsRead(notification.id),
                    tooltip: AppStrings.adminMarkAsReadTooltip,
                  )
                : null,
            onTap: () {
              if (!isRead) {
                controller.markAsRead(notification.id);
              }
              // Could route to specific pages based on type here.
            },
          );
        },
      );
    });
  }

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
