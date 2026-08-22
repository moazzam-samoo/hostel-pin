import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'owner_shell_controller.dart';
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
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Obx(() => IndexedStack(
              index: controller.currentIndex.value,
              children: const [
                DashboardView(),
                ListingsView(),
                AddListingView(),
                OwnerProfileView(),
              ],
            )),
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
