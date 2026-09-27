import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../dashboard/admin_dashboard_view.dart';
import '../users/admin_users_view.dart';
import '../owners/admin_owners_view.dart';
import '../hostels/admin_hostels_view.dart';
import '../notifications/admin_notifications_view.dart';
import '../verifications/admin_verifications_view.dart';
import '../settings/admin_settings_view.dart';
import 'admin_shell_controller.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_top_bar.dart';
import '../../../../core/utils/responsive.dart';

/// Shared shell chrome for all 7 admin sections (Block C.2), built once.
/// White fixed sidebar + orange top bar, matching every one of the 8
/// mockups. Desktop-only per IMPLEMENTATION_PLAN §9.A.1 — this panel was
/// never designed responsive-down-to-phone; the narrow-width branch below
/// is a functional (not pixel-matched) fallback only.
class AdminShellView extends GetView<AdminShellController> {
  const AdminShellView({super.key});

  static const List<Widget> _tabs = [
    AdminDashboardView(),
    AdminUsersView(),
    AdminOwnersView(),
    AdminHostelsView(),
    AdminNotificationsView(),
    AdminVerificationsView(),
    AdminSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    final Widget content = Obx(() => IndexedStack(
          index: controller.currentIndex.value,
          children: _tabs,
        ));

    final topBar = AdminTopBar(
      onSettingsTap: () => controller.changeTab(6),
      onNotificationsTap: () => controller.changeTab(4),
      onAvatarTap: () => controller.changeTab(6),
      avatarUrl: controller.currentAdmin?.photoUrl,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop ? null : topBar,
      body: isDesktop
          ? Column(
              children: [
                topBar,
                Expanded(
                  child: Row(
                    children: [
                      Obx(() => AdminSidebar(
                            currentIndex: controller.currentIndex.value,
                            onTabSelected: controller.changeTab,
                            onLogout: controller.signOut,
                          )),
                      Container(width: 1, color: AppColors.border),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            )
          : content,
      drawer: isDesktop
          ? null
          : Drawer(
              child: Obx(() => AdminSidebar(
                    currentIndex: controller.currentIndex.value,
                    onTabSelected: (idx) {
                      controller.changeTab(idx);
                      Get.back();
                    },
                    onLogout: controller.signOut,
                  )),
            ),
    );
  }
}
