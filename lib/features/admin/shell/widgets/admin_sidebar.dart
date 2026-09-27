import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/feedback/confirm_dialog.dart';

/// Fixed white left sidebar — confirmed against all 8 admin mockups.
/// Order (Block C.2): Dashboard/Users/Owners/Hostels/Notification/
/// Verification Queue/Settings — 7 items, matching AdminShellController's
/// IndexedStack. "Reports" is NOT a sidebar item; it's a tab inside the
/// Notification Center screen (Block F.1), not a top-level destination.
class AdminSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onLogout,
  });

  static const List<_NavItem> _items = [
    _NavItem(Icons.dashboard_outlined, AppStrings.adminNavDashboard),
    _NavItem(Icons.people_outline, AppStrings.adminNavUsers),
    _NavItem(Icons.manage_accounts_outlined, AppStrings.adminNavOwners),
    _NavItem(Icons.apartment_outlined, AppStrings.adminNavHostels),
    _NavItem(Icons.notifications_none, AppStrings.adminNavNotifications),
    _NavItem(Icons.verified_user_outlined, AppStrings.adminNavVerificationQueue),
    _NavItem(Icons.settings_outlined, AppStrings.adminNavSettings),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: _items.length,
              itemBuilder: (context, index) => _buildNavItem(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLogoutPill(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _items[index];
    final isSelected = index == currentIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => onTabSelected(index),
          hoverColor: isSelected ? AppColors.primary : AppColors.surfaceTonal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: (isSelected ? AppTextStyles.body : AppTextStyles.body)
                        .copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutPill(BuildContext context) {
    return Material(
      color: AppColors.errorContainer,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () => _confirmLogout(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: AppColors.error, size: 18),
              const SizedBox(width: 10),
              Text(
                AppStrings.adminSignOut,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      ConfirmDialog(
        title: AppStrings.adminLogoutConfirmTitle,
        message: AppStrings.adminLogoutConfirmMessage,
        confirmText: AppStrings.adminSignOut,
        cancelText: AppStrings.cancelButton,
        isDestructive: true,
        onCancel: () => Get.back(),
        onConfirm: () {
          Get.back();
          onLogout();
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
