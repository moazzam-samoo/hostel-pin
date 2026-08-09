import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../buttons/icon_square_button.dart';

enum AppTopBarVariant { brand, brandWithBack, titled, backOnly, none }

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final AppTopBarVariant variant;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AppTopBar({
    super.key,
    this.variant = AppTopBarVariant.brand,
    this.title,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    if (variant == AppTopBarVariant.none) {
      return const SizedBox.shrink();
    }

    Widget? leading;
    Widget? titleWidget;
    bool centerTitle = false;

    switch (variant) {
      case AppTopBarVariant.brand:
        titleWidget = _buildBrandTitle();
        break;
      case AppTopBarVariant.brandWithBack:
        leading = _buildBackButton(context);
        titleWidget = _buildBrandTitle();
        break;
      case AppTopBarVariant.titled:
        leading = _buildBackButton(context);
        titleWidget = _buildTextTitle();
        centerTitle = true;
        break;
      case AppTopBarVariant.backOnly:
        leading = _buildBackButton(context);
        break;
      case AppTopBarVariant.none:
        break;
    }

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      leadingWidth: leading != null ? 56.0 : 0.0,
      title: titleWidget,
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Center(
        child: IconSquareButton(
          icon: Icons.arrow_back,
          onPressed: onBack ?? () => Navigator.maybePop(context),
        ),
      ),
    );
  }

  Widget _buildBrandTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.appLogo,
          height: 24,
          errorBuilder: (c, e, s) => const Icon(Icons.apartment, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          AppStrings.appName,
          style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTextTitle() {
    return Text(
      title ?? '',
      style: AppTextStyles.screenTitle.copyWith(fontSize: 18),
    );
  }
}
