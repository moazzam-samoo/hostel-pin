import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../media/user_avatar.dart';

class ProfileHeaderBlock extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;
  final VoidCallback? onEdit;

  const ProfileHeaderBlock({
    super.key,
    required this.name,
    required this.email,
    this.imageUrl,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            imageUrl: imageUrl,
            name: name,
            size: 100,
            onTap: onEdit,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            name,
            style: AppTextStyles.screenTitle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            email,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
