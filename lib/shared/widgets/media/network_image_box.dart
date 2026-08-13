import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../feedback/app_loader.dart';

class NetworkImageBox extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkImageBox({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  bool get _isNetwork => imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  Widget _errorBox() => Container(
        width: width,
        height: height,
        color: AppColors.surfaceTonal,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: AppColors.textTertiary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
      // Mock/local data (Phase 3) supplies asset paths; real data (Phase 7,
      // Cloudinary) supplies http(s) URLs. Both are valid `imageUrl` inputs.
      child: _isNetwork
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => Container(
                width: width,
                height: height,
                color: AppColors.surfaceTonal,
                child: const AppLoader(color: AppColors.textSecondary),
              ),
              errorWidget: (context, url, error) => _errorBox(),
            )
          : Image.asset(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _errorBox(),
            ),
    );
  }
}
