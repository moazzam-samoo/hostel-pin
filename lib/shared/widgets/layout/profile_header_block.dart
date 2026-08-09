import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../media/user_avatar.dart'; // We'll create this soon

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
    return Column(
      children: [
        UserAvatar(
          imageUrl: imageUrl,
          name: name,
          size: 100, // AppSizes.avatarLg
          onTap: onEdit,
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          name,
          style: AppTextStyles.screenTitle,
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          email,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
