import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'student_shell_controller.dart';
import '../../../shared/widgets/navigation/app_bottom_nav.dart';
import '../../../shared/widgets/navigation/nav_item.dart';
import '../home/home_view.dart';
import '../map/map_view.dart';
import '../saved/saved_view.dart';
import '../profile/profile_view.dart';

class StudentShellView extends GetView<StudentShellController> {
  const StudentShellView({super.key});

  @override
  Widget build(BuildContext context) {
    // PopScope to handle back button: if not on Home tab, go to Home.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.currentIndex.value != 0) {
          controller.onTabSelected(0);
        } else {
          // If on home, allow normal back/exit behavior by calling Navigator pop
          // Get.back() or SystemNavigator.pop() could be used here depending on requirement
          // Since we are catching the pop, we can force pop.
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: const [
            HomeView(),
            MapView(),
            SavedView(),
            ProfileView(),
          ],
        ),
        bottomNavigationBar: Obx(() => AppBottomNav(
              currentIndex: controller.currentIndex.value,
              onTabSelected: controller.onTabSelected,
              items: const [
                NavItem(
                    label: 'Home',
                    icon: Icons.home_filled,
                    route:
                        ''), // Routes are not really used by this nav implementation for switching tabs
                NavItem(label: 'Map', icon: Icons.map, route: ''),
                NavItem(label: 'Saved', icon: Icons.favorite, route: ''),
                NavItem(label: 'Profile', icon: Icons.person, route: ''),
              ],
            )),
      ),
    );
  }
}
