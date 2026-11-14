import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/listing_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/routes/app_routes.dart';
import '../shell/owner_shell_controller.dart';
import '../../../shared/widgets/layout/app_scaffold.dart';
import '../../../shared/widgets/navigation/app_top_bar.dart';
import '../../../shared/widgets/buttons/primary_button.dart';

class PublishSuccessView extends StatelessWidget {
  const PublishSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    // 2.A: a brand-new listing now arrives here with `status: pending`
    // (awaiting admin review), not `published` — AddListingController
    // passes the resulting status as this route's argument so the copy
    // here never claims a submitted-for-review listing is already live.
    // Any other/missing argument (e.g. an edit that published directly)
    // falls back to the original "published" copy.
    final status = Get.arguments;
    final isPending = status == ListingStatus.pending;

    return AppScaffold(
      topBar: const AppTopBar(
        variant: AppTopBarVariant.none,
      ),
      applyGutter: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 150,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              isPending ? AppStrings.listingSubmittedTitle : AppStrings.listingPublishedTitle,
              style: AppTextStyles.successTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              isPending ? AppStrings.listingSubmittedBody : AppStrings.listingPublishedBody,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: AppStrings.backToDashboardButton,
              onPressed: () {
                // Pop back to the Owner Shell that is already open underneath and
                // show its Dashboard tab. Rebuilding the shell (a second copy of
                // its route) made the old route's cleanup dispose the new shell
                // controller, which left the bottom nav bar dead after adding a
                // hostel.
                Get.until((route) =>
                    route.settings.name == Routes.ownerShell || route.isFirst);
                if (Get.isRegistered<OwnerShellController>()) {
                  Get.find<OwnerShellController>().onTabSelected(0);
                }
              },
              expand: true,
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
