import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  /// Full-width, same height as [PrimaryButton], labelled "Continue with
  /// Google". The default (false) is the original compact "Google" chip,
  /// still used by Signup.
  final bool fullWidth;

  const GoogleAuthButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = fullWidth ? 20.0 : 24.0;
    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          )
        else
          SvgPicture.asset(
            AppAssets.google,
            width: iconSize,
            height: iconSize,
          ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            fullWidth ? AppStrings.continueWithGoogle : 'Google',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button.copyWith(
              color: AppColors.textPrimary,
              fontSize: fullWidth ? 14.sp : null,
            ),
          ),
        ),
      ],
    );

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: fullWidth ? AppSizes.buttonHeight : null,
        padding: fullWidth
            ? const EdgeInsets.symmetric(horizontal: 16)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: AppColors.border),
        ),
        child: content,
      ),
    );
  }
}
