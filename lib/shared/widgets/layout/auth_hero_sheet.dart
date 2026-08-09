import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class AuthHeroSheet extends StatelessWidget {
  final Widget child;

  const AuthHeroSheet({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryVariant,
      child: Column(
        children: [
          // The hero area space can be adjusted by the parent (e.g. Flexible or fixed height)
          const Expanded(child: SizedBox()),
          
          // The bottom sheet area
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheet),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
