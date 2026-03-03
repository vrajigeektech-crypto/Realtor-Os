import 'package:flutter/material.dart';
import '../layout/main_layout.dart';

/// TikTok Listing Walkthrough Screen
/// Brand: Realtor OS – dark gunmetal + rose-gold
class TikTokListingWalkthroughScreen extends StatefulWidget {
  const TikTokListingWalkthroughScreen({super.key});

  @override
  State<TikTokListingWalkthroughScreen> createState() =>
      _TikTokListingWalkthroughScreenState();
}

class _TikTokListingWalkthroughScreenState
    extends State<TikTokListingWalkthroughScreen> {
  // BRAND COLORS
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color accentRose = Color(0xFFCE9799);
  static const Color softBorder = Color(0xFF3E3144);
  static const Color mutedText = Color(0xFF9EA3AE);

  final TextEditingController _addressController = TextEditingController();

  String propertyType = 'House';
  String styleControl = 'Confident';
  String visualStyle = 'Quick Cuts';
  String lookStyle = 'Bright / Modern';

  bool useTikTok = true;
  bool useReels = false;
  bool useShorts = false;
  bool useLinkedIn = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'TikTok Listing Walkthrough',
      activeIndex: 8, // Task
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 16),
                _buildUnlockedPill(),
                const SizedBox(height: 20),
                _buildAddressField(),
                const SizedBox(height: 16),
                _buildPropertyTypeRow(),
                const SizedBox(height: 18),
                _buildStyleControlRow(),
                const SizedBox(height: 14),
                _buildVisualStyleRow(),
                const SizedBox(height: 14),
                _buildLookRow(),
                const SizedBox(height: 20),
                _buildStyleSamplesCard(),
                const SizedBox(height: 20),
                _buildChannelSelection(),
                const SizedBox(height: 28),
                _buildRunButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      "You're creating a TikTok Listing Walkthrough",
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildUnlockedPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentRose.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_open_rounded, size: 14, color: accentRose),
          SizedBox(width: 6),
          Text(
            'Unlocked by your broker',
            style: TextStyle(
              color: accentRose,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Enter Property Address…'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: softBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '1234 Maple Street…',
                    hintStyle: TextStyle(color: mutedText, fontSize: 13),
                  ),
                ),
              ),
              const Icon(Icons.expand_more, color: mutedText, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Property type'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _pillChoice(
              'House',
              propertyType == 'House',
              onTap: () => setState(() => propertyType = 'House'),
            ),
            _pillChoice(
              'Condo',
              propertyType == 'Condo',
              onTap: () => setState(() => propertyType = 'Condo'),
            ),
            _pillChoice(
              'Multi-Family',
              propertyType == 'Multi-Family',
              onTap: () => setState(() => propertyType = 'Multi-Family'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleControlRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Style Control'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _pillChoice(
              'Confident',
              styleControl == 'Confident',
              onTap: () => setState(() => styleControl = 'Confident'),
            ),
            _pillChoice(
              'Warm',
              styleControl == 'Warm',
              onTap: () => setState(() => styleControl = 'Warm'),
            ),
            _pillChoice(
              'Educational',
              styleControl == 'Educational',
              onTap: () => setState(() => styleControl = 'Educational'),
            ),
            _pillChoice(
              'Luxury',
              styleControl == 'Luxury',
              onTap: () => setState(() => styleControl = 'Luxury'),
            ),
            _pillChoice(
              'Playful',
              styleControl == 'Playful',
              onTap: () => setState(() => styleControl = 'Playful'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualStyleRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Visual Style'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _pillChoice(
              'Clean Walkthrough',
              visualStyle == 'Clean Walkthrough',
              onTap: () => setState(() => visualStyle = 'Clean Walkthrough'),
            ),
            _pillChoice(
              'Text Overlay',
              visualStyle == 'Text Overlay',
              onTap: () => setState(() => visualStyle = 'Text Overlay'),
            ),
            _pillChoice(
              'Cinematic',
              visualStyle == 'Cinematic',
              onTap: () => setState(() => visualStyle = 'Cinematic'),
            ),
            _pillChoice(
              'Quick Cuts',
              visualStyle == 'Quick Cuts',
              onTap: () => setState(() => visualStyle = 'Quick Cuts'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLookRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Look'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _pillChoice(
              'Bright / Modern',
              lookStyle == 'Bright / Modern',
              onTap: () => setState(() => lookStyle = 'Bright / Modern'),
            ),
            _pillChoice(
              'Dark / Moody',
              lookStyle == 'Dark / Moody',
              onTap: () => setState(() => lookStyle = 'Dark / Moody'),
            ),
            _pillChoice(
              'Brand Default',
              lookStyle == 'Brand Default',
              onTap: () => setState(() => lookStyle = 'Brand Default'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleSamplesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Style Samples',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _sampleThumbnail()),
              const SizedBox(width: 8),
              Expanded(child: _sampleThumbnail(showPlay: true)),
              const SizedBox(width: 8),
              Expanded(child: _sampleThumbnail()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sampleThumbnail({bool showPlay = false}) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: softBorder),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF26262C), Color(0xFF15151A)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 36,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'Sample',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
            if (showPlay)
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 20,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelSelection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Channel Selection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _channelCheckbox('TikTok', useTikTok, (v) {
            setState(() => useTikTok = v ?? false);
          }),
          _channelCheckbox('Instagram Reels', useReels, (v) {
            setState(() => useReels = v ?? false);
          }),
          _channelCheckbox('YouTube Shorts', useShorts, (v) {
            setState(() => useShorts = v ?? false);
          }),
          _channelCheckbox('LinkedIn', useLinkedIn, (v) {
            setState(() => useLinkedIn = v ?? false);
          }),
          const SizedBox(height: 6),
          const Text(
            "We'll adapt format and captions automatically.",
            style: TextStyle(color: mutedText, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _channelCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: value,
      onChanged: onChanged,
      activeColor: accentRose,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildRunButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRose,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: () {
          // Hook up to your generation workflow here.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Running TikTok Listing Walkthrough…'),
            ),
          );
        },
        child: const Text(
          'Run this for me',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: mutedText,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _pillChoice(String text, bool selected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? accentRose : softBorder),
          color: selected
              ? accentRose.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.05),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : mutedText,
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
