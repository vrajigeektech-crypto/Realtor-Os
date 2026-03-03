import 'package:flutter/material.dart';
import '../layout/main_layout.dart';
import '../utils/app_styles.dart';
import '../widgets/task_header_card.dart';

/// Realtor OS – SLA & Time Control Panel
/// Refactored to use MainLayout and Project Theme.
class SlaTimeControlPanelScreen extends StatefulWidget {
  const SlaTimeControlPanelScreen({super.key});

  @override
  State<SlaTimeControlPanelScreen> createState() =>
      _SlaTimeControlPanelScreenState();
}

class _SlaTimeControlPanelScreenState extends State<SlaTimeControlPanelScreen> {
  // Using Rose Gold as the accent effectively

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'SLA Time Control',
      activeIndex: 8, // Task or similar
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TaskHeaderCard(isMobile: isMobile),
                const SizedBox(height: 20),
                if (isMobile)
                  _buildMobileClockSection()
                else
                  _buildCenterClockRow(),
                const SizedBox(height: 22),
                const Divider(height: 0, color: AppStyles.borderSoft),
                const SizedBox(height: 16),
                _buildPauseResumeSection(isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  // SLA clock with side summary cards
  Widget _buildCenterClockRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _infoTile(
                title: 'SLA State',
                mainText: 'On Track',
                leadingIcon: Icons.check_circle_outline,
                mainColor: Colors.lightGreenAccent,
              ),
              const SizedBox(height: 12),
              _infoTile(
                title: 'Time Elapsed',
                mainText: '11h 13m',
                leadingIcon: Icons.hourglass_bottom,
                mainColor: AppStyles.mutedText,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildClock(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _infoTile(
                title: 'End Time',
                mainText: 'Due Today at 6:12 PM',
                leadingIcon: Icons.schedule,
                mainColor: Colors.white,
                alignRight: true,
              ),
              const SizedBox(height: 12),
              _infoTile(
                title: 'Paused 0x —',
                mainText: '11h 13m',
                leadingIcon: Icons.pause_circle_outline,
                mainColor: AppStyles.mutedText,
                alignRight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileClockSection() {
    return Column(
      children: [
        _buildClock(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _infoTile(
                title: 'SLA State',
                mainText: 'On Track',
                leadingIcon: Icons.check_circle_outline,
                mainColor: Colors.lightGreenAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoTile(
                title: 'Time Elapsed',
                mainText: '11h 13m',
                leadingIcon: Icons.hourglass_bottom,
                mainColor: AppStyles.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _infoTile(
                title: 'End Time',
                mainText: 'Due 6:12 PM',
                leadingIcon: Icons.schedule,
                mainColor: Colors.white,
                alignRight: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoTile(
                title: 'Paused',
                mainText: '11h 13m',
                leadingIcon: Icons.pause_circle_outline,
                mainColor: AppStyles.mutedText,
                alignRight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClock() {
    return Container(
      width: 260,
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFF3E3144), // Border Soft
            Color(0xFFCE9799), // Accent Rose
            Color(0xFF3E3144),
          ],
          startAngle: 0.0,
          endAngle: 6.28318, // 2π
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF141414), Color(0xFF0E0A0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.black87, width: 3),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '54m 23s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Due Today at 6:12 PM',
                style: TextStyle(color: AppStyles.mutedText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _infoTile({
    required String title,
    required String mainText,
    required IconData leadingIcon,
    required Color mainColor,
    bool alignRight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Row(
        children: [
          if (!alignRight)
            Icon(leadingIcon, size: 18, color: mainColor)
          else
            const SizedBox.shrink(),
          if (!alignRight) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: alignRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppStyles.mutedText,
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  mainText,
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: alignRight ? TextAlign.right : TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (alignRight) const SizedBox(width: 8),
          if (alignRight)
            Icon(leadingIcon, size: 18, color: mainColor)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  // Pause / Resume section
  Widget _buildPauseResumeSection(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildPausedSlaCard(),
          const SizedBox(height: 16),
          _buildPauseControlsCard(),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pause / Resume',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPausedSlaCard()),
            const SizedBox(width: 18),
            Expanded(child: _buildPauseControlsCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildPausedSlaCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_outlined,
                size: 18,
                color: AppStyles.accentRose,
              ),
              SizedBox(width: 6),
              Text(
                'Paused SLA:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Task queued for client revision.',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppStyles.borderSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _CheckboxLine(label: 'Dependency', checked: true),
                SizedBox(height: 6),
                _CheckboxLine(label: 'Waiting on Client', checked: true),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Message over Email:\nClient has requested changes to Reel video. '
            'Pending review before resuming SLA.',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 11.5),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.accentRose,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resuming SLA sequence...')),
                );
              },
              child: const Text(
                'Resume SLA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseControlsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppStyles.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyles.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Pause SLA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const _SlaToggle(),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pause SLA — timer will stop until resumed manually.',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 11.5),
          ),
          const SizedBox(height: 14),
          const Text(
            'Reason',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 11.5),
          ),
          const SizedBox(height: 4),
          const _DropdownField(
            value: 'Waiting on Client',
            options: ['Dependency', 'Waiting on Client', 'Internal Review'],
          ),
          const SizedBox(height: 10),
          const Text(
            'Category',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 11.5),
          ),
          const SizedBox(height: 4),
          const _DropdownField(
            value: 'Dependency',
            options: ['Dependency', 'Waiting on Client', 'May need revisions'],
          ),
          const SizedBox(height: 10),
          const Text(
            'Client has requested changes to Reel video. Pending review before resuming SLA.',
            style: TextStyle(color: AppStyles.mutedText, fontSize: 11.5),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppStyles.borderSoft),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Root Cause', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxLine extends StatelessWidget {
  const _CheckboxLine({required this.label, this.checked = false});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: checked ? AppStyles.accentRose : const Color(0xFF3C323C),
              width: 1.4,
            ),
            color: checked
                ? AppStyles.accentRose.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: checked
              ? const Icon(Icons.check, size: 12, color: AppStyles.accentRose)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF9EA3AE), fontSize: 11.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SlaToggle extends StatefulWidget {
  const _SlaToggle();

  @override
  State<_SlaToggle> createState() => _SlaToggleState();
}

class _SlaToggleState extends State<_SlaToggle> {
  bool value = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => value = !value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? AppStyles.accentRose : const Color(0xFF3C323C),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.value, required this.options});

  final String value;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3C323C)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9EA3AE)),
          dropdownColor: const Color(0xFF241C25),
          style: const TextStyle(color: Colors.white, fontSize: 12.5),
          items: options
              .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}
