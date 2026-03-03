import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class PhotoUploadService {
  static final PhotoUploadService _instance = PhotoUploadService._();
  static PhotoUploadService get instance => _instance;
  PhotoUploadService._();

  Future<List<String>> pickAndUploadPhotos({bool multiple = true}) async {
    // For now, only support mobile since web requires dart:html
    return _pickAndUploadPhotosMobile(multiple: multiple);
  }

  Future<List<String>> _pickAndUploadPhotosMobile({
    required bool multiple,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: multiple,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return [];

    final bytesList = <Uint8List>[];
    final names = <String>[];

    for (final f in result.files) {
      if (f.bytes == null) continue;
      bytesList.add(f.bytes!);
      names.add(f.name);
    }

    if (bytesList.isEmpty) return [];

    return uploadGalleryFromBytes(bytesList, names);
  }

  Future<List<String>> uploadGalleryFromBytes(
    List<Uint8List> bytesList,
    List<String> names,
  ) async {
    final supabase = SupabaseService.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final bucket = supabase.storage.from('user_assets');
    final baseTs = DateTime.now().millisecondsSinceEpoch;
    final uploadedUrls = <String>[];

    for (var i = 0; i < bytesList.length; i++) {
      final bytes = bytesList[i];
      final name = names[i];
      final ext = _ext(name);
      final mime = _mime(ext);

      final path = '${user.id}/gallery/${baseTs}_$i.png';

      debugPrint(
        '📤 [PhotoUpload] Upload started: $path (bytes ${bytes.length})',
      );

      await bucket.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: mime, upsert: true),
      );

      final url = bucket.getPublicUrl(path);
      uploadedUrls.add(url);

      debugPrint('✅ [PhotoUpload] Upload success URL: $url');
    }

    return uploadedUrls;
  }

  Future<String> uploadLogoFromBytes(Uint8List bytes) async {
    final supabase = SupabaseService.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final bucket = supabase.storage.from('user_assets');
    final path = '${user.id}/logo/logo.png';

    debugPrint('[LogoUpload] Uploading to path: $path');
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
    );

    final url = bucket.getPublicUrl(path);
    debugPrint('[LogoUpload] Public URL: $url');
    return url;
  }

  Future<String> uploadHeadshotFromBytes(Uint8List bytes) async {
    final supabase = SupabaseService.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final bucket = supabase.storage.from('user_assets');
    final path = '${user.id}/headshot/headshot.png';

    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
    );

    return bucket.getPublicUrl(path);
  }

  Future<void> saveGalleryUrls(List<String> urls) async {
    final supabase = SupabaseService.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase
        .from('users')
        .update({'gallery_urls': urls})
        .eq('id', user.id);

    await supabase.rpc(
      'complete_onboarding_step',
      params: {'p_step': 'upload_selfies', 'p_user_id': user.id},
    );
  }

  String _ext(String name) {
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot + 1).toLowerCase() : 'png';
  }

  String _mime(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/png';
    }
  }
}
