import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'owner_shell_controller.dart';
import 'widgets/add_listing_gate_view.dart';
import '../../../core/enums/verification_status.dart';
import '../../../data/services/session_service.dart';
import '../../../shared/widgets/navigation/app_bottom_nav.dart';
import '../../../shared/widgets/navigation/nav_item.dart';
import '../dashboard/dashboard_view.dart';
import '../listings/listings_view.dart';
import '../add_listing/add_listing_view.dart';
import '../profile/owner_profile_view.dart';

class OwnerShellView extends GetView<OwnerShellController> {
  const OwnerShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = Get.find<SessionService>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.currentIndex.value != 0) {
          controller.onTabSelected(0);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: [
            const DashboardView(),
            const ListingsView(),
            // 2.B — the Add tab is gated behind full identity verification.
            // Obx here (not a one-time check) so an owner approved while the
            // app is open sees the gate lift immediately, without a restart.
            Obx(() {
              final isVerified = sessionService.currentUser.value?.verificationStatus ==
                  VerificationStatus.verified;
              return isVerified ? const AddListingView() : const AddListingGateView();
            }),
            const OwnerProfileView(),
          ],
        ),
        bottomNavigationBar: Obx(() => AppBottomNav(
              currentIndex: controller.currentIndex.value,
              onTabSelected: controller.onTabSelected,
              items: const [
                NavItem(label: 'Dashboard', icon: Icons.dashboard, route: ''),
                NavItem(label: 'Listing', icon: Icons.list_alt, route: ''),
                NavItem(
                    label: 'Add', icon: Icons.add_circle_outline, route: ''),
                NavItem(label: 'Profile', icon: Icons.person, route: ''),
              ],
            )),
      ),
    );
  }
}
