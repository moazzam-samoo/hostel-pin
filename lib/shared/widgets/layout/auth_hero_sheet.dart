import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../buttons/icon_square_button.dart';

class AuthHeroSheet extends StatelessWidget {
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;

  const AuthHeroSheet({
    super.key,
    required this.child,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryVariant,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top hero bar with optional back button
            SizedBox(
              height: 56.0,
              child: showBack
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: IconSquareButton(
                          icon: Icons.arrow_back,
                          onPressed: onBack ?? () => Get.back(),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            
            // The curved bottom sheet area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sheet),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

