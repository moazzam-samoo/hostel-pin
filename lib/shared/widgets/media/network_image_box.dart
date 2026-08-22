import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

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

  bool get _isNetwork =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  // Bundled assets always live under 'assets/' (see AppAssets); anything
  // else that isn't a network URL is a local on-device file path — e.g.
  // image_picker's XFile.path from Owner Add Listing's photo upload
  // (Phase 4) before Phase 7 wires real Cloudinary uploads.
  bool get _isAsset => imageUrl.startsWith('assets/');

  Widget _errorBox() => Image.asset(
        'assets/images/placeholder_hostel.png',
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceTonal,
          child: const Center(
            child:
                Icon(Icons.apartment, color: AppColors.textTertiary, size: 28),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.card),
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
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _errorBox(),
            )
          : _isAsset
              ? Image.asset(
                  imageUrl,
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) => _errorBox(),
                )
              : Image.file(
                  File(imageUrl),
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) => _errorBox(),
                ),
    );
  }
}
