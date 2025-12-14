import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class SupabaseStorageService {
  final _supabase = Supabase.instance.client;
  final String bucketName = 'reports';

  /// Upload single image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadImage({
    required XFile imageFile,
    required String userId,
    String? reportId,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = '${timestamp}_${path.basename(imageFile.path)}';

      // Create folder structure: reports/{userId}/{timestamp}/
      final folderPath = 'reports/$userId/${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';
      final filePath = '$folderPath/$fileName';

      debugPrint('📤 Uploading image to: $filePath');

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      final response = await _supabase.storage.from(bucketName).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/${extension.replaceAll('.', '')}',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(filePath);

      debugPrint('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload video and generate thumbnail
  /// Returns a map with video URL and thumbnail URL
  Future<Map<String, String>> uploadVideo({
    required XFile videoFile,
    required String userId,
    String? reportId,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(videoFile.path);
      final fileName = '${timestamp}_${path.basename(videoFile.path)}';

      // Create folder structure: reports/{userId}/{timestamp}/
      final folderPath = 'reports/$userId/${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';
      final videoPath = '$folderPath/$fileName';

      debugPrint('📤 Uploading video to: $videoPath');

      // Read file as bytes
      final bytes = await videoFile.readAsBytes();

      // Upload video to Supabase Storage
      await _supabase.storage.from(bucketName).uploadBinary(
            videoPath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'video/${extension.replaceAll('.', '')}',
              upsert: false,
            ),
          );

      // Get public URL for video
      final videoUrl = _supabase.storage.from(bucketName).getPublicUrl(videoPath);
      debugPrint('✅ Video uploaded successfully: $videoUrl');

      // Generate thumbnail
      String? thumbnailUrl;
      try {
        debugPrint('🎬 Generating video thumbnail...');
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoFile.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 512,
          quality: 75,
        );

        if (thumbnailPath != null) {
          // Upload thumbnail
          final thumbnailFileName = '${timestamp}_thumb.jpg';
          final thumbnailStoragePath = '$folderPath/$thumbnailFileName';

          final thumbnailBytes = await File(thumbnailPath).readAsBytes();
          await _supabase.storage.from(bucketName).uploadBinary(
                thumbnailStoragePath,
                thumbnailBytes,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: false,
                ),
              );

          thumbnailUrl = _supabase.storage.from(bucketName).getPublicUrl(thumbnailStoragePath);
          debugPrint('✅ Thumbnail uploaded successfully: $thumbnailUrl');

          // Clean up local thumbnail file
          await File(thumbnailPath).delete();
        }
      } catch (e) {
        debugPrint('⚠️ Error generating thumbnail: $e');
        // Continue without thumbnail
      }

      return {
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl ?? '',
      };
    } catch (e) {
      debugPrint('❌ Error uploading video: $e');
      rethrow;
    }
  }

  /// Upload multiple media files (images and videos)
  /// Returns a list of maps with URLs and metadata
  Future<List<Map<String, dynamic>>> uploadMultipleMedia({
    required List<Map<String, dynamic>> mediaItems,
    required String userId,
    String? reportId,
    Function(int current, int total)? onProgress,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < mediaItems.length; i++) {
      try {
        final item = mediaItems[i];
        final file = item['file'] as XFile;
        final type = item['type'] as String; // 'image' or 'video'

        onProgress?.call(i + 1, mediaItems.length);

        if (type == 'image') {
          final url = await uploadImage(
            imageFile: file,
            userId: userId,
            reportId: reportId,
          );
          results.add({
            'type': 'image',
            'url': url,
            'thumbnailUrl': null,
          });
        } else if (type == 'video') {
          final uploadResult = await uploadVideo(
            videoFile: file,
            userId: userId,
            reportId: reportId,
          );
          results.add({
            'type': 'video',
            'url': uploadResult['videoUrl'],
            'thumbnailUrl': uploadResult['thumbnailUrl'],
          });
        }
      } catch (e) {
        debugPrint('❌ Error uploading media item ${i + 1}: $e');
        // Continue with other files even if one fails
        results.add({
          'type': 'error',
          'url': '',
          'thumbnailUrl': null,
          'error': e.toString(),
        });
      }
    }

    return results;
  }

  /// Delete a file from Supabase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
      debugPrint('🗑️ File deleted: $filePath');
    } catch (e) {
      debugPrint('❌ Error deleting file: $e');
      rethrow;
    }
  }

  /// Extract file path from public URL
  /// Example: https://xxx.supabase.co/storage/v1/object/public/reports/path/file.jpg -> path/file.jpg
  String extractFilePathFromUrl(String publicUrl) {
    final uri = Uri.parse(publicUrl);
    final segments = uri.pathSegments;

    // Find 'public' segment and get everything after it
    final publicIndex = segments.indexOf('public');
    if (publicIndex != -1 && publicIndex < segments.length - 1) {
      // Skip bucket name (next segment after 'public')
      final pathSegments = segments.sublist(publicIndex + 2);
      return pathSegments.join('/');
    }

    return '';
  }
}
