import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class IconSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color iconColor;
  final double size;

  const IconSquareButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.borderColor = AppColors.secondary,
    this.iconColor = AppColors.secondary,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: borderColor),
          color: AppColors.background,
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
