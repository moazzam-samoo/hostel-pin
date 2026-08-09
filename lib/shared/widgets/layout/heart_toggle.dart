import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HeartToggle extends StatelessWidget {
  final bool isLiked;
  final ValueChanged<bool> onToggle;

  const HeartToggle({
    super.key,
    required this.isLiked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isLiked),
      behavior: HitTestBehavior.opaque,
      child: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? AppColors.heartActive : AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
