import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/upload_result_model.dart';
import 'cloudinary_service.dart';
import '../../core/utils/logger.dart';

/// Thrown when a multi-photo upload gives up partway (FIX-7.8).
///
/// Carries the `public_id`s that *did* reach Cloudinary before the failure.
/// The caller must not write a listing document referencing them — those
/// assets are now orphaned, and this list is what lets them be swept later
/// (see `functions/` — a client cannot issue a signed destroy itself).
class PartialUploadException implements Exception {
  final String message;
  final List<String> orphanedPublicIds;

  const PartialUploadException(this.message, this.orphanedPublicIds);

  @override
  String toString() => message;
}

class StorageService {
  final CloudinaryService _cloudinaryService;
  final Uuid _uuid = const Uuid();

  /// How many times a single file is retried before the batch gives up.
  /// Cloudinary uploads fail transiently often enough on mobile networks
  /// that one shot per photo made multi-photo publishes flaky (FIX-7.8).
  static const int _maxAttempts = 3;

  StorageService({CloudinaryService? cloudinaryService})
      : _cloudinaryService = cloudinaryService ?? CloudinaryService();

  /// Compresses an image and uploads it to Cloudinary, retrying transient
  /// failures with a short backoff. Used for single uploads like avatars.
  Future<UploadResultModel> uploadImage(
    File file,
    String folder, {
    void Function(double progress)? onProgress,
  }) async {
    File? compressedFile;
    try {
      compressedFile = await _compressImage(file);

      Object? lastError;
      for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
        try {
          return await _cloudinaryService.uploadImage(
            compressedFile,
            folder,
            onProgress: onProgress,
          );
        } catch (e) {
          lastError = e;
          if (attempt == _maxAttempts) break;
          // Linear backoff — long enough to ride out a brief drop, short
          // enough that the user isn't staring at a spinner for a dead link.
          await Future<void>.delayed(Duration(seconds: attempt * 2));
          Logger.w('Upload attempt $attempt failed, retrying: $e');
        }
      }
      // CloudinaryService already throws a clean, user-facing message —
      // don't wrap it again (that's how "Network is unreachable" DioException
      // text used to end up rendered raw in an AppSnackbar three layers up).
      throw lastError!;
    } catch (e) {
      Logger.e('StorageService upload error: $e');
      rethrow;
    } finally {
      // Always remove the temp file, including on the failure paths above,
      // which previously leaked one compressed copy per failed upload.
      if (compressedFile != null && compressedFile.path != file.path) {
        try {
          await compressedFile.delete();
        } catch (_) {
          // A leftover temp file is not worth failing the upload over.
        }
      }
    }
  }

  /// Compresses and uploads multiple images for a hostel listing.
  ///
  /// Uploads are sequential on purpose (FIX-7.8): the previous
  /// `Future.wait` fired every photo at once, so one failure left an
  /// unknown number of siblings mid-flight with no way to know which had
  /// landed. Sequential means the set of successful uploads is always known
  /// exactly, which is what makes orphan reporting possible.
  ///
  /// [onFileProgress] reports `(index, progress)` per file so the UI can
  /// show "photo 2 of 5 — 40%".
  Future<List<UploadResultModel>> uploadImages(
    List<File> files,
    String folder, {
    void Function(int index, double progress)? onFileProgress,
  }) async {
    final uploaded = <UploadResultModel>[];
    for (var i = 0; i < files.length; i++) {
      try {
        final result = await uploadImage(
          files[i],
          folder,
          onProgress: onFileProgress == null
              ? null
              : (p) => onFileProgress(i, p),
        );
        uploaded.add(result);
      } catch (e) {
        Logger.e('Batch upload failed on file ${i + 1}/${files.length}: $e');
        throw PartialUploadException(
          e.toString().replaceFirst('Exception: ', ''),
          uploaded.map((u) => u.publicId).toList(),
        );
      }
    }
    return uploaded;
  }

  /// Compresses the given file using flutter_image_compress
  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${_uuid.v4()}.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80, // Cloudinary will also auto-quality, but this saves bandwidth
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      Logger.w('Image compression failed, returning original file');
      return file;
    }

    return File(result.path);
  }
}
