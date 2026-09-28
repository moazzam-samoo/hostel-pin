import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

/// Full-width orange top bar — confirmed identical across all 8 admin
/// mockups (Dashboard/Users/Owners/Hostels/Notification/Verification/
/// Review/Settings): "HostelPin" wordmark + home icon at left, a search
/// field + settings icon + notification-bell icon + circular avatar at
/// right. Shared by AdminShellView and (via AdminSidebar) any screen that
/// needs the same chrome outside the shell's own IndexedStack tabs.
class AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;

  const AdminTopBar({
    super.key,
    this.onSettingsTap,
    this.onNotificationsTap,
    this.onAvatarTap,
    this.avatarUrl,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      color: AppColors.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context)) ...[
            Builder(
              builder: (ctx) => IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Open Navigation',
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.home_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: AppTextStyles.screenTitle.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Responsive.isDesktop(context)
              ? SizedBox(
                  width: 320,
                  height: 40,
                  // Not wired to a real search query anywhere in this phase's
                  // scope (no admin-facing global search was named in any Block
                  // D-H checklist item) — a real, typeable field kept purely
                  // visual-parity with the mockup, same "don't fabricate a
                  // feature the plan never scoped" discipline as the AI-match
                  // badge and Settings' Global System card.
                  child: TextField(
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: AppStrings.adminTopBarSearchHint,
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                )
              : _iconButton(Icons.search, () {}),
          const SizedBox(width: 12),
          _iconButton(Icons.settings_outlined, onSettingsTap),
          const SizedBox(width: 10),
          _iconButton(Icons.notifications_none_rounded, onNotificationsTap),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? const Icon(Icons.person, color: AppColors.secondary)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: AppColors.secondary, size: 22),
        ),
      ),
    );
  }
}
