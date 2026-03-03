import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../services/photo_upload_service.dart';
import '../services/supabase_service.dart';
import '../web_file_input.dart';

class LogoUploadScreen extends StatefulWidget {
  final VoidCallback? onSaveContinue;

  const LogoUploadScreen({super.key, this.onSaveContinue});

  @override
  State<LogoUploadScreen> createState() => _LogoUploadScreenState();
}

class _LogoUploadScreenState extends State<LogoUploadScreen> {
  bool _uploading = false;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      setLogoFileCallback(_onLogoFileSelected);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      setLogoFileCallback(null);
    }
    super.dispose();
  }

  void _onLogoFileSelected(Uint8List bytes, String name) {
    if (!mounted || _uploading) return;
    debugPrint('[LogoUpload] Picker opened');
    debugPrint('[LogoUpload] Bytes received: ${bytes.length}');
    debugPrint('[LogoUpload] Filename: $name');
    _uploadLogo(bytes);
  }

  Future<void> _pickLogoFile() async {
    if (kIsWeb) return; // Web uses the callback system
    
    debugPrint('[LogoUpload] Starting file picker...');
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      debugPrint('[LogoUpload] File picker result: $result');
      debugPrint('[LogoUpload] Files count: ${result?.files.length ?? 0}');

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        debugPrint('[LogoUpload] Selected file: ${file.name}, bytes available: ${file.bytes != null}, path: ${file.path}');
        
        Uint8List? bytes;
        
        if (file.bytes != null) {
          bytes = file.bytes!;
          debugPrint('[LogoUpload] Using bytes from file.bytes, length: ${bytes.length}');
        } else if (file.path != null) {
          debugPrint('[LogoUpload] Reading bytes from file path: ${file.path}');
          bytes = await File(file.path!).readAsBytes();
          debugPrint('[LogoUpload] Read bytes from path, length: ${bytes.length}');
        }
        
        if (bytes != null) {
          debugPrint('[LogoUpload] Calling _uploadLogo with ${bytes.length} bytes');
          _uploadLogo(bytes);
        } else {
          debugPrint('[LogoUpload] No bytes available for upload');
        }
      } else {
        debugPrint('[LogoUpload] No files selected');
      }
    } catch (e) {
      debugPrint('[LogoUpload] Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _uploadLogo(Uint8List bytes) async {
    final supabase = SupabaseService.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('[LogoUpload] Error: User not authenticated');
      return;
    }

    debugPrint('[LogoUpload] Starting upload for user: ${user.id}');
    debugPrint('[LogoUpload] Bytes length: ${bytes.length}');

    try {
      setState(() => _uploading = true);

      final url = await PhotoUploadService.instance.uploadLogoFromBytes(bytes);
      debugPrint('[LogoUpload] Upload successful, URL: $url');

      if (!mounted) return;

      debugPrint('[LogoUpload] Saving logo_url to users table');
      await supabase.from('users').update({'logo_url': url}).eq('id', user.id);

      debugPrint('[LogoUpload] Calling award_xp_for_event(upload_logo)');
      await supabase.rpc(
        'award_xp_for_event',
        params: {
          'p_user_id': user.id,
          'p_event_key': 'upload_logo',
          'p_event_ref': user.id,
        },
      );

      debugPrint('[LogoUpload] Upload complete');
      if (mounted) setState(() => _logoUrl = url);
    } catch (e) {
      debugPrint('[LogoUpload] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !_uploading;
    final canContinue = _logoUrl != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'UPLOAD LOGO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Center(
                child: kIsWeb
                    ? buildLogoFileInput(
                        enabled: enabled,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _logoUrl == null
                              ? const Center(child: Icon(Icons.add, size: 32))
                              : Image.network(
                                  _logoUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    debugPrint('[LogoUpload] Image render failed');
                                    return const Center(
                                      child: Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                        ),
                      )
                    : GestureDetector(
                        onTap: enabled ? _pickLogoFile : null,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _logoUrl == null
                              ? const Center(child: Icon(Icons.add, size: 32))
                              : Image.network(
                                  _logoUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    debugPrint('[LogoUpload] Image render failed');
                                    return const Center(
                                      child: Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Center(
                child: kIsWeb
                    ? buildLogoFileInput(
                        enabled: enabled,
                        child: SizedBox(
                          width: 200,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: enabled ? () {} : null, // Make it clickable for web file input
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFd4a574),
                              foregroundColor: Colors.black,
                            ),
                            child: Text(_uploading ? 'Uploading…' : 'Browse Files'),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: enabled ? _pickLogoFile : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFd4a574),
                            foregroundColor: Colors.black,
                          ),
                          child: Text(_uploading ? 'Uploading…' : 'Browse Files'),
                        ),
                      ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () => widget.onSaveContinue?.call()
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
