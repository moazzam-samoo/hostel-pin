import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/upload_result_model.dart';
import 'cloudinary_service.dart';
import '../../core/utils/logger.dart';

class StorageService {
  final CloudinaryService _cloudinaryService;
  final Uuid _uuid = const Uuid();

  StorageService({CloudinaryService? cloudinaryService})
      : _cloudinaryService = cloudinaryService ?? CloudinaryService();

  /// Compresses an image and uploads it to Cloudinary.
  /// Used for single uploads like avatars.
  Future<UploadResultModel> uploadImage(File file, String folder) async {
    try {
      final compressedFile = await _compressImage(file);
      final result = await _cloudinaryService.uploadImage(compressedFile, folder);
      
      // Clean up compressed temp file
      if (compressedFile.path != file.path) {
        await compressedFile.delete();
      }
      
      return result;
    } catch (e) {
      // CloudinaryService already throws a clean, user-facing message —
      // don't wrap it again (that's how "Network is unreachable" DioException
      // text used to end up rendered raw in an AppSnackbar three layers up).
      Logger.e('StorageService upload error: $e');
      rethrow;
    }
  }

  /// Compresses and uploads multiple images concurrently.
  /// Used for hostel listing photos.
  Future<List<UploadResultModel>> uploadImages(List<File> files, String folder) async {
    try {
      final uploadTasks = files.map((file) => uploadImage(file, folder));
      final results = await Future.wait(uploadTasks);
      return results;
    } catch (e) {
      Logger.e('StorageService batch upload error: $e');
      throw Exception('Failed to upload multiple images: $e');
    }
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
