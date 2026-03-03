import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

/// Realtor OS – Upload for Client Review Screen
class UploadForClientReviewScreen extends StatelessWidget {
  const UploadForClientReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Upload for Review',
      activeIndex: 8, // Task
      child: const _UploadForReviewLayout(),
    );
  }
}

class _UploadForReviewLayout extends StatelessWidget {
  const _UploadForReviewLayout();

  // Brand palette
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color borderSoft = Color(0xFF3E3144);
  static const Color accentRose = Color(0xFFCE9799);
  static const Color mutedText = Color(0xFF9EA3AE);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(height: 0, color: borderSoft),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTaskHeaderCard(),
                    const SizedBox(height: 16),
                    _buildUploadAssetsSection(),
                    const SizedBox(height: 18),
                    _buildPreviewAndMessageSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top title bar
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      // color: panelColor, // Transparent
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Upload for Client Review',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Deliver completed assets for client approval or posting.',
            style: TextStyle(color: mutedText, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  // Task header card (Frank Miller)
  Widget _buildTaskHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade700,
            child: const Text(
              'FM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Task ID: #8731',
                  style: TextStyle(color: mutedText, fontSize: 11),
                ),
                SizedBox(height: 2),
                Text(
                  'Frank Miller',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Miller Realty',
                  style: TextStyle(color: mutedText, fontSize: 12),
                ),
                SizedBox(height: 6),
                _TaskMetaRow(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: borderSoft),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.music_note, size: 16, color: Colors.white70),
                SizedBox(width: 6),
                Text(
                  'TikTok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Upload assets section
  Widget _buildUploadAssetsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Assets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drag & drop finished assets here or click to browse files.',
            style: TextStyle(color: mutedText, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildAssetTypeRow(),
          const SizedBox(height: 12),
          const Divider(height: 0, color: borderSoft),
          const SizedBox(height: 10),
          const _AssetRow(
            leadingLabel: 'Video',
            fileName: 'Marketing_Reel_R.mp4',
            fileSize: '86 MB',
          ),
          const SizedBox(height: 8),
          const _AssetRow(
            leadingLabel: 'Brand',
            fileName: 'New_Logo_Final.png',
            fileSize: '820 KB',
          ),
          const SizedBox(height: 8),
          const _AssetRow(
            leadingLabel: 'MP3',
            fileName: 'Full_Audio_Voiceover.mp3',
            fileSize: '5.2 MB',
          ),
          const SizedBox(height: 10),
          const Text(
            'Delivered Reel Promo Video for TikTok. TikTok aspect ratio and formatting previewed only.',
            style: TextStyle(color: mutedText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTypeRow() {
    Widget chip(String label, IconData icon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderSoft),
          color: Colors.black.withValues(alpha: 0.25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: mutedText),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: mutedText, fontSize: 11.5),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        chip('Video (MP4)', Icons.play_circle_outline),
        chip('Image (PNG, JPG)', Icons.image_outlined),
        chip('Audio (MP3)', Icons.graphic_eq),
        chip('Copy/Notes (Text)', Icons.notes_outlined),
      ],
    );
  }

  // Preview + message + approval
  Widget _buildPreviewAndMessageSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview & Select Channel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildChannelRow(),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildPhonePreview(),
                    const SizedBox(height: 16),
                    _buildMessageCard(),
                    const SizedBox(height: 14),
                    _buildApprovalModeCard(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhonePreview(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMessageCard(),
                        const SizedBox(height: 14),
                        _buildApprovalModeCard(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRow() {
    Widget btn(String label, IconData icon, {bool selected = false}) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? accentRose : borderSoft),
            color: selected ? accentRose.withValues(alpha: 0.12) : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? accentRose : Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : mutedText,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        btn('TikTok', Icons.music_note, selected: true),
        btn('Instagram Reels', Icons.camera_alt_outlined),
        // btn('YouTube Shorts', Icons.play_circle_outline),
        // btn('Email', Icons.email_outlined),
      ],
    );
  }

  Widget _buildPhonePreview() {
    return Container(
      width: 150,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade800,
            ),
            child: const Center(
              child: Icon(
                Icons.video_library_outlined,
                size: 32,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Stunning New Listing!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'TikTok aspect preview placeholder.',
            style: TextStyle(color: mutedText, fontSize: 9.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Message to Client',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hi Frank,\n\n'
            'Here’s the completed reel for the listing walkthrough, along with the '
            'updated logo and voiceover track.\n\n'
            'Please take a moment to review everything.\n'
            'Let me know if any changes are needed.',
            style: TextStyle(color: mutedText, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalModeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Approval Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _radioRow(
            selected: true,
            label: 'Manual Approval Required',
            description:
                'Client must manually approve before post is published.',
          ),
          const SizedBox(height: 8),
          _radioRow(
            selected: false,
            label: 'Auto-Post After Approval',
            description:
                'Post will automatically publish after client approval.',
          ),
        ],
      ),
    );
  }

  Widget _radioRow({
    required bool selected,
    required String label,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? accentRose : borderSoft,
              width: 1.4,
            ),
          ),
          child: selected
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentRose,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(color: mutedText, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskMetaRow extends StatelessWidget {
  const _TaskMetaRow();

  @override
  Widget build(BuildContext context) {
    Text meta(String text) => Text(
      text,
      style: const TextStyle(color: Color(0xFF9EA3AE), fontSize: 11),
    );

    return Row(
      children: [
        const Icon(Icons.task_alt, size: 12, color: Color(0xFF9EA3AE)),
        const SizedBox(width: 4),
        meta('57 Tasks · Joined'),
        const SizedBox(width: 10),
        const Icon(Icons.calendar_today, size: 11, color: Color(0xFF9EA3AE)),
        const SizedBox(width: 4),
        meta('Tasks · Joined Sep 2023'),
      ],
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.leadingLabel,
    required this.fileName,
    required this.fileSize,
  });

  final String leadingLabel;
  final String fileName;
  final String fileSize;

  @override
  Widget build(BuildContext context) {
    const borderSoft = Color(0xFF3E3144);
    const mutedText = Color(0xFF9EA3AE);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Center(
              child: Text(
                leadingLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileSize,
                  style: const TextStyle(color: mutedText, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _actionButton('Replace'),
          const SizedBox(width: 8),
          _actionButton('Remove'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderSoft),
            ),
            child: const Icon(Icons.more_horiz, size: 14, color: mutedText),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF3E3144)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        textStyle: const TextStyle(fontSize: 11.5),
      ),
      onPressed: () {},
      child: Text(label),
    );
  }
}
