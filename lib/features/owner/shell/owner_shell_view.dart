import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'owner_add_access.dart';
import 'owner_shell_controller.dart';
import 'widgets/add_listing_gate_view.dart';
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.currentIndex.value != 0) {
          controller.onTabSelected(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: PageView(
          controller: controller.pageController,
          // Tabs change only via the bottom navigation bar, never by swiping.
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: controller.onPageChanged,
          children: [
            const DashboardView(),
            const ListingsView(),
            // The Add tab follows OwnerShellController.addAccess: the real form
            // while the owner may add a hostel (verified, or identity submitted
            // with fewer than kMaxPendingHostels in review), the gate otherwise.
            Obx(() => controller.addAccess.value == OwnerAddAccess.allowed
                ? const AddListingView()
                : AddListingGateView(access: controller.addAccess.value)),
            const OwnerProfileView(),
          ],
        ),
        bottomNavigationBar: Obx(() => AppBottomNav(
              currentIndex: controller.currentIndex.value,
              onTabSelected: controller.onTabSelected,
              items: const [
                NavItem(label: 'Dashboard', icon: Icons.grid_view_rounded, route: ''),
                NavItem(label: 'Listing', icon: Icons.apartment_rounded, route: ''),
                NavItem(label: 'Add', icon: Icons.add_circle_outline_rounded, route: ''),
                NavItem(label: 'Profile', icon: Icons.person_rounded, route: ''),
              ],
            )),
      ),
    );
  }
}
