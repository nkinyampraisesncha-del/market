import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final _uuid = const Uuid();
  final _picker = ImagePicker();

  static const String _profileBucket = 'avatars';
  static const String _listingsBucket = 'listings';

  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  Future<XFile?> pickImageFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  Future<List<XFile>> pickMultipleImages({int limit = 5}) async {
    final images = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
      limit: limit,
    );
    return images;
  }

  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    final extension = imageFile.path.split('.').last.toLowerCase();
    final fileName = '$userId/avatar.$extension';

    final bytes = await imageFile.readAsBytes();

    await _client.storage.from(_profileBucket).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$extension',
            upsert: true,
          ),
        );

    return _client.storage.from(_profileBucket).getPublicUrl(fileName);
  }

  Future<String> uploadListingImage(String sellerId, XFile imageFile) async {
    final extension = imageFile.path.split('.').last.toLowerCase();
    final fileName = '$sellerId/${_uuid.v4()}.$extension';

    final bytes = await imageFile.readAsBytes();

    await _client.storage.from(_listingsBucket).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$extension',
            upsert: false,
          ),
        );

    return _client.storage.from(_listingsBucket).getPublicUrl(fileName);
  }

  Future<List<String>> uploadListingImages(
      String sellerId, List<XFile> images) async {
    final urls = <String>[];
    for (final image in images) {
      final url = await uploadListingImage(sellerId, image);
      urls.add(url);
    }
    return urls;
  }

  Future<void> deleteImage(String bucket, String path) async {
    await _client.storage.from(bucket).remove([path]);
  }

  Future<void> deleteListingImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(_listingsBucket);
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final path = pathSegments.sublist(bucketIndex + 1).join('/');
        await deleteImage(_listingsBucket, path);
      }
    }
  }

  Future<File> getTemporaryFile(XFile xFile) async {
    return File(xFile.path);
  }
}
