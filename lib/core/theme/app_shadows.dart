import 'package:flutter/material.dart';

class AppShadows {
  static const none = <BoxShadow>[];

  static final card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Soft, wide, borderless-card shadow used by every hostel card.
  static final softCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static final nav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, -4),
    ),
  ];
}
