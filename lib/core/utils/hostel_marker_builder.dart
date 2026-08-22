import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

Future<BitmapDescriptor> buildHostelMarkerBitmap({
  required String name,
  required bool isSelected,
  double pixelRatio = 3.0,
}) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final Color stateColor = isSelected ? AppColors.markerSelected : AppColors.primary;
  
  // Measure text
  final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: name,
    style: AppTextStyles.caption.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 12 * pixelRatio,
    ),
  );
  textPainter.layout();

  final double paddingX = 12.0 * pixelRatio;
  final double paddingY = 8.0 * pixelRatio;
  
  final double chipWidth = textPainter.width + (paddingX * 2);
  final double chipHeight = textPainter.height + (paddingY * 2);
  final double chipRadius = 16.0 * pixelRatio;

  final double stemHeight = 12.0 * pixelRatio;
  final double stemWidth = 2.0 * pixelRatio;
  
  final double pinRadius = 8.0 * pixelRatio;
  final double dotRadius = 3.0 * pixelRatio;
  final double pinTailLength = 6.0 * pixelRatio;
  final double pinTotalHeight = (pinRadius * 2) + pinTailLength;

  final double totalWidth = chipWidth;
  final double totalHeight = chipHeight + stemHeight + pinTotalHeight;

  // Draw chip
  final Paint paint = Paint()..color = stateColor;
  final RRect chipRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, chipWidth, chipHeight),
    Radius.circular(chipRadius),
  );
  canvas.drawRRect(chipRect, paint);

  // Draw text
  textPainter.paint(canvas, Offset(paddingX, paddingY));

  // Draw stem
  final double centerX = totalWidth / 2;
  canvas.drawRect(
    Rect.fromLTWH(centerX - (stemWidth / 2), chipHeight, stemWidth, stemHeight),
    paint,
  );

  // Draw teardrop pin
  final double pinCenterY = chipHeight + stemHeight + pinRadius;
  
  final Path pinPath = Path();
  pinPath.addArc(
    Rect.fromCircle(center: Offset(centerX, pinCenterY), radius: pinRadius),
    0,
    3.14159 * 2,
  );
  
  // Triangle tail pointing down
  final Path tailPath = Path();
  tailPath.moveTo(centerX - pinRadius * 0.8, pinCenterY + pinRadius * 0.5);
  tailPath.lineTo(centerX + pinRadius * 0.8, pinCenterY + pinRadius * 0.5);
  tailPath.lineTo(centerX, pinCenterY + pinRadius + pinTailLength);
  tailPath.close();
  
  canvas.drawPath(pinPath, paint);
  canvas.drawPath(tailPath, paint);

  // Draw center dot
  final Paint dotPaint = Paint()..color = Colors.white;
  canvas.drawCircle(Offset(centerX, pinCenterY), dotRadius, dotPaint);

  final ui.Image image = await pictureRecorder.endRecording().toImage(
    totalWidth.toInt(),
    totalHeight.toInt(),
  );
  
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List bytes = byteData!.buffer.asUint8List();

  // The canvas above was drawn at `pixelRatio`x scale for crispness — tell
  // the SDK that via imagePixelRatio, or MapBitmapScaling.auto (the
  // default) renders the raw pixel count 1:1 as logical pixels, making the
  // marker ~pixelRatio times too large on screen.
  return BitmapDescriptor.bytes(bytes, imagePixelRatio: pixelRatio);
}
