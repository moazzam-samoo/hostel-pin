import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ConfettiDot {
  final Alignment alignment;
  final double size;
  final Color color;

  const ConfettiDot({
    required this.alignment,
    required this.size,
    required this.color,
  });
}

/// Decorative dots scattered around a logo (Welcome, Login).
/// Positions/colors are supplied as data via [dots] rather than hardcoded
/// per screen, so every screen that needs this effect gets one consistent
/// default and can override it if a mockup ever calls for a different layout.
class ConfettiDots extends StatelessWidget {
  final Widget child;
  final double canvasSize;
  final List<ConfettiDot> dots;

  static const List<ConfettiDot> defaultDots = [
    ConfettiDot(
        alignment: Alignment(1.15, -0.85), size: 14, color: AppColors.dotPink),
    ConfettiDot(
        alignment: Alignment(-1.25, -0.15), size: 10, color: AppColors.dotCyan),
    ConfettiDot(
        alignment: Alignment(-0.95, 1.05), size: 12, color: AppColors.dotAmber),
    ConfettiDot(
        alignment: Alignment(1.05, 0.95), size: 8, color: AppColors.dotBlue),
  ];

  const ConfettiDots({
    super.key,
    required this.child,
    this.canvasSize = 180,
    this.dots = defaultDots,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Center(child: child),
          for (final dot in dots)
            Align(
              alignment: dot.alignment,
              child: Container(
                width: dot.size,
                height: dot.size,
                decoration: BoxDecoration(
                  color: dot.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
