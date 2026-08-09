import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'network_image_box.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 250.0,
    this.borderRadius,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceTonal,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.card),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: AppColors.textTertiary),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return NetworkImageBox(
                imageUrl: widget.imageUrls[index],
                width: double.infinity,
                height: double.infinity,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.card),
              );
            },
          ),
        ),
        Positioned(
          bottom: AppSpacing.md,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageUrls.asMap().entries.map((entry) {
              final isSelected = _currentIndex == entry.key;
              return Container(
                width: isSelected ? 16.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.background : AppColors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
