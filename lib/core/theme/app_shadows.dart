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

  static final nav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, -4),
    ),
  ];
}
