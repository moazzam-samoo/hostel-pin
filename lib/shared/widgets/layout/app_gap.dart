import 'package:flutter/material.dart';

class AppGap extends StatelessWidget {
  final double? height;
  final double? width;

  const AppGap({super.key, this.height, this.width});

  const AppGap.xs({super.key}) : height = 4.0, width = 4.0;
  const AppGap.sm({super.key}) : height = 8.0, width = 8.0;
  const AppGap.md({super.key}) : height = 12.0, width = 12.0;
  const AppGap.lg({super.key}) : height = 24.0, width = 24.0;
  const AppGap.xl({super.key}) : height = 32.0, width = 32.0;

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
