// record_script_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../services/record_script_service.dart';

class RecordScriptScreen extends StatefulWidget {
  const RecordScriptScreen({
    super.key,
    this.scriptText,
    this.maxDuration = const Duration(minutes: 3),
  });

  final String? scriptText;
  final Duration maxDuration;

  @override
  State<RecordScriptScreen> createState() => _RecordScriptScreenState();
}

class _RecordScriptScreenState extends State<RecordScriptScreen> {
  bool _isRecording = false;
  bool _uploading = false;
  Duration _elapsed = Duration.zero;
  String _fileName = 'No file selected';

  Timer? _tick;
  Timer? _waveTick;

  final List<double> _samples = List<double>.filled(48, 0.12);

  @override
  void initState() {
    super.initState();
    _startWaveSim();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _waveTick?.cancel();
    super.dispose();
  }

  void _startWaveSim() {
    _waveTick?.cancel();
    _waveTick = Timer.periodic(const Duration(milliseconds: 140), (_) {
      if (!_isRecording) return;
      setState(() {
        _samples.removeAt(0);
        _samples.add(_randAmp());
      });
    });
  }

  double _randAmp() {
    final r = math.Random();
    final base = 0.08 + r.nextDouble() * 0.22;
    final spike = r.nextDouble() < 0.08 ? (0.35 + r.nextDouble() * 0.45) : 0.0;
    return (base + spike).clamp(0.06, 0.98);
  }

  void _toggleRecord() {
    final next = !_isRecording;

    setState(() {
      _isRecording = next;
      if (_isRecording) {
        _tick?.cancel();
        _tick = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          if (_elapsed >= widget.maxDuration) {
            _toggleRecord();
            return;
          }
          setState(() => _elapsed += const Duration(seconds: 1));
        });
      } else {
        _tick?.cancel();
      }
    });
  }

  Future<void> _uploadFile() async {
    if (_uploading) return;

    setState(() => _uploading = true);

    try {
      final url = await VoiceUploadService.instance.pickAndUploadVoice();
      if (!mounted || url == null) return;

      setState(() {
        _fileName = url.split('/').last;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice uploaded successfully'),
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

  void _saveContinue() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tokens = _RecordTokens.fromTheme(t);

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentW = constraints.maxWidth.clamp(0, 700).toDouble();

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentW),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Breadcrumb(
                        text: 'AUDIO RECORDING  >  RECORD SCRIPT',
                        color: tokens.mutedText,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'RECORD SCRIPT',
                        style: t.textTheme.headlineSmall?.copyWith(
                          color: tokens.titleText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: _GlassPanel(
                          border: Border.all(
                            color: tokens.panelBorder,
                            width: 1,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                _ScriptBox(
                                  text:
                                      widget.scriptText ??
                                      'Script will appear here for reading...',
                                  border: tokens.panelBorder,
                                  fill: tokens.cardFill,
                                  textColor: tokens.bodyText,
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    const Spacer(),
                                    _WaveCircle(
                                      samples: _samples,
                                      accent: tokens.accent,
                                      ring: tokens.accent.withOpacity(0.45),
                                      fill: tokens.cardFill.withOpacity(0.35),
                                    ),
                                    const SizedBox(width: 18),
                                    _Timecode(
                                      left: _format(_elapsed),
                                      right: _format(widget.maxDuration),
                                      color: tokens.mutedText,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _PrimaryButton(
                                  label: _isRecording ? 'STOP' : 'RECORD',
                                  onPressed: _toggleRecord,
                                  bg: tokens.accent.withOpacity(0.72),
                                  fg: tokens.buttonText,
                                  border: BorderSide(
                                    color: tokens.accent.withOpacity(0.55),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _UploadRow(
                                  accent: tokens.accent,
                                  border: tokens.panelBorder,
                                  fill: tokens.cardFill,
                                  fileName: _fileName,
                                  textColor: tokens.bodyText,
                                  muted: tokens.mutedText,
                                  onUpload: _uploading ? null : _uploadFile,
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _PrimaryButton(
                                    label: 'SAVE & CONTINUE',
                                    onPressed: _saveContinue,
                                    bg: tokens.accent.withOpacity(0.72),
                                    fg: tokens.buttonText,
                                    border: BorderSide(
                                      color: tokens.accent.withOpacity(0.55),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _format(Duration d) {
    final total = d.inSeconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

/// ---------- UI TOKENS + WIDGETS (UNCHANGED BELOW) ----------
/// (everything below this line is identical to what you already had)

class _RecordTokens {
  final Color bg;
  final Color panelBorder;
  final Color titleText;
  final Color bodyText;
  final Color mutedText;
  final Color accent;
  final Color cardFill;
  final Color buttonText;

  const _RecordTokens({
    required this.bg,
    required this.panelBorder,
    required this.titleText,
    required this.bodyText,
    required this.mutedText,
    required this.accent,
    required this.cardFill,
    required this.buttonText,
  });

  factory _RecordTokens.fromTheme(ThemeData t) {
    final cs = t.colorScheme;
    return _RecordTokens(
      bg: t.scaffoldBackgroundColor,
      panelBorder: cs.outlineVariant.withOpacity(0.22),
      titleText: cs.onSurface.withOpacity(0.95),
      bodyText: cs.onSurface.withOpacity(0.82),
      mutedText: cs.onSurface.withOpacity(0.60),
      accent: cs.primary,
      cardFill: cs.surface.withOpacity(0.06),
      buttonText: cs.onPrimary,
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.border});
  final Widget child;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: border,
        color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
      ),
      child: child,
    );
  }
}

class _ScriptBox extends StatelessWidget {
  const _ScriptBox({
    required this.text,
    required this.border,
    required this.fill,
    required this.textColor,
  });

  final String text;
  final Color border;
  final Color fill;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.35),
      ),
    );
  }
}

class _WaveCircle extends StatelessWidget {
  const _WaveCircle({
    required this.samples,
    required this.accent,
    required this.ring,
    required this.fill,
  });

  final List<double> samples;
  final Color accent;
  final Color ring;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _WaveCirclePainter(
          samples: samples,
          accent: accent,
          ring: ring,
          fill: fill,
        ),
      ),
    );
  }
}

class _WaveCirclePainter extends CustomPainter {
  _WaveCirclePainter({
    required this.samples,
    required this.accent,
    required this.ring,
    required this.fill,
  });

  final List<double> samples;
  final Color accent;
  final Color ring;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide / 2 - 4;

    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = fill);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = ring
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    final n = samples.length;
    if (n < 2) return;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      final angle = -math.pi / 2 + t * 2 * math.pi;
      final amp = (samples[i].clamp(0.0, 1.0) - 0.5) * r * 0.6;
      final x = cx + (r + amp) * math.cos(angle);
      final y = cy + (r + amp) * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveCirclePainter old) => true;
}

class _Timecode extends StatelessWidget {
  const _Timecode({
    required this.left,
    required this.right,
    required this.color,
  });
  final String left;
  final String right;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$left / $right',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.bg,
    required this.fg,
    required this.border,
  });

  final String label;
  final VoidCallback onPressed;
  final Color bg;
  final Color fg;
  final BorderSide border;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: border,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({
    required this.accent,
    required this.border,
    required this.fill,
    required this.fileName,
    required this.textColor,
    required this.muted,
    required this.onUpload,
  });

  final Color accent;
  final Color border;
  final Color fill;
  final String fileName;
  final Color textColor;
  final Color muted;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: onUpload,
            child: const Text('Upload Sound File'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
