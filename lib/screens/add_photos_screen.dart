import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/photo_upload_service.dart';

class AddPhotosScreen extends StatefulWidget {
  const AddPhotosScreen({super.key});

  @override
  State<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  static const int maxSlots = 6;

  final List<String> _uploadedUrls = [];
  bool _uploading = false;

  Future<void> _pickPhotos() async {
    if (_uploading) return;

    try {
      setState(() => _uploading = true);

      final urls = await PhotoUploadService.instance.pickAndUploadPhotos(
        multiple: true,
      );

      if (!mounted || urls.isEmpty) return;

      setState(() {
        _uploadedUrls
          ..addAll(urls)
          ..removeRange(
            maxSlots,
            _uploadedUrls.length > maxSlots ? _uploadedUrls.length : maxSlots,
          );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${urls.length} photo(s) uploaded'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _handleSaveContinue() async {
    if (_uploadedUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one photo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() => _uploading = true);

      await PhotoUploadService.instance.saveGalleryUrls(_uploadedUrls);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photos saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PHOTO GALLERY',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 16),

              /// GRID
              Expanded(
                child: GridView.builder(
                  itemCount: maxSlots,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, i) {
                    if (i < _uploadedUrls.length) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _uploadedUrls[i],
                          fit: BoxFit.cover,
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: _uploading ? null : _pickPhotos,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: t.colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
                        child: const Center(child: Icon(Icons.add, size: 28)),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// BROWSE BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _pickPhotos,
                  child: Text(_uploading ? 'Uploading…' : 'Browse Files'),
                ),
              ),

              const SizedBox(height: 12),

              /// SAVE
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _handleSaveContinue,
                  child: const Text('SAVE & CONTINUE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
