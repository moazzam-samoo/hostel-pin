import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import '../models/upload_result_model.dart';
import '../../core/config/cloudinary_config.dart';
import '../../core/utils/logger.dart';

// CloudinaryPublic defaults to a bare Dio() when no client is supplied, and
// Dio's own default timeouts are all null (unbounded) — it just waits on
// whatever the platform socket does, which on a broken/unreachable network
// can take well over a minute before failing. Explicit timeouts make a dead
// network fail predictably in seconds instead of leaving the UI stuck on
// "loading" with no feedback.
Dio _timeoutBoundDioClient() => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 60), // photo bytes, needs headroom
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

class CloudinaryService {
  final CloudinaryPublic _cloudinaryHostels = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.hostelsPreset,
    cache: false,
    dioClient: _timeoutBoundDioClient(),
  );

  final CloudinaryPublic _cloudinaryAvatars = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.avatarsPreset,
    cache: false,
    dioClient: _timeoutBoundDioClient(),
  );

  /// Uploads a single image to the specified folder preset.
  ///
  /// [onProgress] reports 0.0–1.0 for this one file (FIX-7.14) so a
  /// multi-photo publish can show real per-file progress instead of an
  /// indeterminate spinner. Cloudinary reports sent/total bytes; `total` is
  /// -1 when the length is unknown, which is reported as indeterminate by
  /// simply not emitting.
  Future<UploadResultModel> uploadImage(
    File file,
    String folder, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final cloudinary = folder == 'hostels' ? _cloudinaryHostels : _cloudinaryAvatars;

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, folder: folder),
        onProgress: onProgress == null
            ? null
            : (count, total) {
                if (total > 0) onProgress((count / total).clamp(0.0, 1.0));
              },
      );

      return UploadResultModel(
        url: response.secureUrl,
        publicId: response.publicId,
      );
    } on DioException catch (e) {
      Logger.e('Cloudinary upload error: $e');
      // Network-shaped failures (device/router genuinely can't reach
      // Cloudinary, or the request timed out per the client above) get one
      // clear, non-technical message instead of a raw DioException dump —
      // that's the string that ends up on-screen in an AppSnackbar.
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('No internet connection. Check your network and try again.');
        default:
          throw Exception('Could not upload photo. Please try again.');
      }
    } catch (e) {
      Logger.e('Cloudinary upload error: $e');
      throw Exception('Could not upload photo. Please try again.');
    }
  }
}
