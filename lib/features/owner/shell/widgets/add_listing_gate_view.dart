import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../owner_add_access.dart';
import '../owner_shell_controller.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/navigation/app_top_bar.dart';

/// 2.B — shown instead of the real Add Listing form when the signed-in
/// owner isn't fully identity-verified yet. Reuses EmptyState (icon/title/
/// message) plus a PrimaryButton for the call to action, rather than
/// inventing new visual language for a gated state this app doesn't already
/// have a pattern for elsewhere.
///
/// Only gates the Owner Shell's Add tab (a brand-new listing) — editing an
/// existing listing via the Listings tab's Edit action goes through
/// Routes.ownerEdit, a separate call site this widget never touches, since
/// an already-published listing implies the owner was already verified
/// when it was approved.
class AddListingGateView extends StatelessWidget {
  final OwnerAddAccess access;

  const AddListingGateView({super.key, required this.access});

  @override
  Widget build(BuildContext context) {
    final limitReached = access == OwnerAddAccess.limitReached;

    return Scaffold(
      appBar: const AppTopBar(
        variant: AppTopBarVariant.titled,
        title: AppStrings.addHostel,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyState(
                icon: Icons.verified_user_outlined,
                title: limitReached
                    ? AppStrings.addTabLimitReachedTitle
                    : AppStrings.addTabGateTitle,
                message: switch (access) {
                  OwnerAddAccess.limitReached => AppStrings.addTabLimitReachedMessage,
                  OwnerAddAccess.rejected => AppStrings.addTabRejectedMessage,
                  _ => AppStrings.addTabGateMessage,
                },
              ),
              SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                text: limitReached
                    ? AppStrings.addTabLimitReachedButton
                    : AppStrings.addTabGateButton,
                onPressed: () {
                  if (limitReached) {
                    Get.find<OwnerShellController>().onTabSelected(1);
                  } else {
                    Get.toNamed(Routes.ownerVerification);
                  }
                },
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
