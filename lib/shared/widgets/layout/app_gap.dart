import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
class AppGap extends StatelessWidget {
  final double? height;
  final double? width;

  const AppGap({super.key, this.height, this.width});

  AppGap.xs({super.key}) : height = AppSpacing.xs, width = AppSpacing.xs;
  AppGap.sm({super.key}) : height = AppSpacing.sm, width = AppSpacing.sm;
  AppGap.md({super.key}) : height = AppSpacing.md, width = AppSpacing.md;
  AppGap.lg({super.key}) : height = AppSpacing.lg, width = AppSpacing.lg;
  AppGap.xl({super.key}) : height = AppSpacing.xl, width = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    if (height != null && width != null) {
      // Typically used for either vertical or horizontal, but context decides
      // To be safe we just supply both or specific named constructors which 
      // rely on Flutter ignoring the unneeded dimension inside flex layouts.
      return SizedBox(height: height, width: width);
    }
    return SizedBox(height: height, width: width);
  }
}
