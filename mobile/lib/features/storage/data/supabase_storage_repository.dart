import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/storage_repository.dart';

/// Supabase implementation of [StorageRepository].
///
/// Uses Supabase Storage for file operations with built-in CDN support.
/// The bucket name is configured via environment variables.
class SupabaseStorageRepository implements StorageRepository {
  final SupabaseClient _supabase;
  final String _bucketName;

  SupabaseStorageRepository(
    this._supabase, {
    String bucketName = 'audit-photos',
  }) : _bucketName = bucketName;

  @override
  Future<String> upload({
    required String path,
    required List<int> data,
    required String mimeType,
  }) async {
    final bytes = Uint8List.fromList(data);

    await _supabase.storage.from(_bucketName).uploadBinary(path, bytes,
        fileOptions: FileOptions(contentType: mimeType));

    // Return public URL - Supabase Storage auto-generates public URLs
    final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(path);

    return publicUrl;
  }

  @override
  Future<List<int>> download(String url) async {
    // Extract path from Supabase URL if full URL provided
    final path = _extractPath(url);

    final response = await _supabase.storage.from(_bucketName).download(path);

    return response;
  }

  @override
  Future<void> delete(String url) async {
    final path = _extractPath(url);

    await _supabase.storage.from(_bucketName).remove([path]);
  }

  @override
  Future<List<String>> uploadMultiple(List<UploadRequest> uploads) async {
    final results = <String>[];

    for (final upload in uploads) {
      final url = await uploadFile(
        path: upload.path,
        data: upload.data,
        mimeType: upload.mimeType,
      );
      results.add(url);
    }

    return results;
  }

  /// Internal method to upload a single file (avoid naming conflict with interface method)
  Future<String> uploadFile({
    required String path,
    required List<int> data,
    required String mimeType,
  }) async {
    return upload(path: path, data: data, mimeType: mimeType);
  }

  /// Extracts the storage path from a full Supabase Storage URL.
  String _extractPath(String url) {
    // Handle full URLs like: https://xxx.supabase.co/storage/v1/object/public/audit-photos/audits/xyz.jpg
    if (url.contains('/storage/')) {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      // Path segments after 'object' and 'public' (or 'signed')
      // Pattern: storage/v1/object/public/bucket/path/to/file
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
    }
    // Return as-is if it's already a path
    return url;
  }
}
