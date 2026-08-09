import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum MapPanelMode { readonly, picker }

/// Placeholder map surface used by the Detail screen (readonly) and the
/// Owner Add form (picker, taps out to a full-screen location picker).
/// Renders the dark panel + "Drop your location" chip shown in the mockups;
/// the real map tiles are wired in once google_maps_flutter is added.
class MapPanel extends StatelessWidget {
  final MapPanelMode mode;
  final String label;
  final double height;
  final VoidCallback? onTap;

  const MapPanel({
    super.key,
    this.mode = MapPanelMode.readonly,
    this.label = 'Drop your location',
    this.height = 180,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: mode == MapPanelMode.picker ? onTap : null,
        child: Container(
          height: height,
          width: double.infinity,
          color: AppColors.darkSurface,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.chipNeutral,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gps_fixed, size: 16, color: AppColors.textPrimary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
