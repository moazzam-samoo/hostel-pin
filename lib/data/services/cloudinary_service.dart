import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../models/upload_result_model.dart';
import 'auth_service.dart';
import '../../core/config/cloudinary_config.dart';
import '../../core/config/edge_signer_config.dart';
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

  /// Uploads an identity or verification document to the `verification` folder via
  /// a signed request. The asset is stored as `type: authenticated` and returns
  /// a `public_id` (not a URL) per Phase 8 requirements.
  ///
  /// The signature itself comes from a Cloudflare Worker
  /// (`cloudflare-worker/`, see its README), not a Firebase Cloud Function —
  /// Firebase's free Spark plan can't deploy Cloud Functions at all,
  /// and this project deliberately stays off the paid Blaze plan. The
  /// Worker holds the Cloudinary API secret instead and verifies the
  /// caller's Firebase ID token itself before signing anything.
  Future<String> uploadSignedDocument(
    File file,
    String uid,
    String kind,
  ) async {
    try {
      final idToken = await Get.find<AuthService>().currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('You must be signed in to upload a document.');
      }

      final dio = _timeoutBoundDioClient();

      final sigResponse = await dio.post(
        '${EdgeSignerConfig.baseUrl}/signature',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      final data = sigResponse.data as Map<String, dynamic>;
      final timestamp = data['timestamp'];
      final signature = data['signature'] as String;
      final apiKey = data['api_key'] as String;
      final cloudName = data['cloud_name'] as String;
      final folder = data['folder'] as String;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'timestamp': timestamp,
        'signature': signature,
        'api_key': apiKey,
        'folder': folder,
        'type': 'authenticated',
      });

      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/auto/upload',
        data: formData,
      );

      return response.data['public_id'] as String;
    } on DioException catch (e) {
      Logger.e('Cloudinary signed upload error: $e');
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('No internet connection. Check your network and try again.');
        default:
          throw Exception('Could not upload document. Please try again.');
      }
    } catch (e) {
      Logger.e('Cloudinary signed upload error: $e');
      throw Exception('Could not upload document. Please try again.');
    }
  }
}
