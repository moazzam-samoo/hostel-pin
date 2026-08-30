import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/hostel_marker_builder.dart';

enum MapPanelMode { readonly, picker }

/// Map surface used by the Detail screen (readonly, a hostel's location)
/// and the Owner Add form (picker, taps out to a full-screen location
/// picker). Renders a real, non-interactive Google Maps preview — a single
/// marker, gestures disabled, `liteModeEnabled` on Android — when
/// [latitude]/[longitude] are supplied; falls back to the dark "Drop your
/// location" placeholder chip otherwise (e.g. before Add Listing has a
/// picked location, or in the widget gallery with no coordinates).
class MapPanel extends StatefulWidget {
  final MapPanelMode mode;
  final String label;
  final double height;
  final VoidCallback? onTap;
  final double? latitude;
  final double? longitude;
  final String? markerLabel;

  const MapPanel({
    super.key,
    this.mode = MapPanelMode.readonly,
    this.label = 'Drop your location',
    this.height = 180,
    this.onTap,
    this.latitude,
    this.longitude,
    this.markerLabel,
  });

  @override
  State<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<MapPanel> {
  BitmapDescriptor? _customIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  @override
  void didUpdateWidget(MapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.markerLabel != oldWidget.markerLabel) {
      _loadCustomMarker();
    }
  }

  Future<void> _loadCustomMarker() async {
    if (widget.markerLabel != null) {
      final icon = await buildHostelMarkerBitmap(
        name: widget.markerLabel!,
        isSelected: true,
      );
      if (mounted) {
        setState(() {
          _customIcon = icon;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = widget.latitude != null && widget.longitude != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: widget.mode == MapPanelMode.picker ? widget.onTap : null,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasLocation)
                // In picker mode, we ignore map pointers so the InkWell can
                // receive the tap to open the full-screen picker.
                // In readonly mode, the map is interactive (zoom/scroll).
                IgnorePointer(
                  ignoring: widget.mode == MapPanelMode.picker,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.latitude!, widget.longitude!),
                      zoom: 15,
                    ),
                    liteModeEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: widget.mode == MapPanelMode.readonly,
                    scrollGesturesEnabled: widget.mode == MapPanelMode.readonly,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('panel_location'),
                        position: LatLng(widget.latitude!, widget.longitude!),
                        icon: _customIcon ?? BitmapDescriptor.defaultMarker,
                      ),
                    },
                  ),
                )
              else
                Container(color: AppColors.darkSurface),
              if (widget.markerLabel == null)
                Center(
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
                        const Icon(Icons.gps_fixed,
                            size: 16, color: AppColors.textPrimary),
                        SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            widget.label,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
