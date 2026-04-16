/// Abstract storage repository for cloud-agnostic file storage.
///
/// This interface allows the app to work with different storage backends
/// (Supabase Storage, AWS S3, Google Cloud Storage, etc.) without changing
/// the business logic layer.
///
/// Implementation: [SupabaseStorageRepository]
abstract class StorageRepository {
  /// Uploads a file and returns its public URL.
  ///
  /// [path] - The destination path within the storage bucket (e.g., 'audits/vehicle-123/photo.jpg')
  /// [data] - The file bytes to upload
  /// [mimeType] - The MIME type of the file
  ///
  /// Returns the public URL to access the uploaded file.
  Future<String> upload({
    required String path,
    required List<int> data,
    required String mimeType,
  });

  /// Downloads a file and returns its bytes.
  ///
  /// [url] - The public URL or storage path of the file to download.
  Future<List<int>> download(String url);

  /// Deletes a file from storage.
  ///
  /// [url] - The public URL or storage path of the file to delete.
  Future<void> delete(String url);

  /// Uploads multiple files concurrently.
  ///
  /// [uploads] - List of upload requests containing path, data, and mimeType.
  /// Returns list of public URLs for all uploaded files in order.
  Future<List<String>> uploadMultiple(List<UploadRequest> uploads);
}

/// Request object for batch uploads.
class UploadRequest {
  final String path;
  final List<int> data;
  final String mimeType;

  const UploadRequest({
    required this.path,
    required this.data,
    required this.mimeType,
  });
}
