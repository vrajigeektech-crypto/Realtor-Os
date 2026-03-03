import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class VoiceUploadService {
  static final VoiceUploadService _instance = VoiceUploadService._();
  static VoiceUploadService get instance => _instance;
  VoiceUploadService._();

  Future<String?> pickAndUploadVoice() async {
    // For now, only support mobile since web requires dart:html
    return _pickAndUploadVoiceMobile();
  }

  Future<String?> _pickAndUploadVoiceMobile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'm4a', 'aac'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.bytes == null) return null;

    return uploadVoiceFromBytes(file.bytes!, file.name);
  }

  Future<String> uploadVoiceFromBytes(Uint8List bytes, String fileName) async {
    final supabase = SupabaseService.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ext = _ext(fileName);
    final mime = _mime(ext);

    final bucket = supabase.storage.from('user_assets');
    final path =
        '${user.id}/voice/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: mime, upsert: true),
    );

    final url = bucket.getPublicUrl(path);

    await supabase.from('users').update({'voice_url': url}).eq('id', user.id);

    await supabase.rpc(
      'complete_onboarding_step',
      params: {'p_step': 'upload_voice', 'p_user_id': user.id},
    );

    return url;
  }

  String _ext(String name) {
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot + 1).toLowerCase() : 'wav';
  }

  String _mime(String ext) {
    switch (ext) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      default:
        return 'audio/wav';
    }
  }
}
