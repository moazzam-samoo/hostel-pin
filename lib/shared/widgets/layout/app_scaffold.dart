import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../navigation/app_top_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppTopBar? topBar;
  final Widget? bottomNav;
  final bool useSafeArea;
  final bool applyGutter;
  final Color backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.topBar,
    this.bottomNav,
    this.useSafeArea = true,
    this.applyGutter = true,
    this.backgroundColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (applyGutter) {
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: content,
      );
    }

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: topBar,
      bottomNavigationBar: bottomNav,
      body: content,
    );
  }
}
