// leaderboard_activity_trend_sparkline.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../models/leaderboard_agent_model.dart';

class LeaderboardActivityTrendSparkline extends StatelessWidget {
  const LeaderboardActivityTrendSparkline({
    super.key,
    required this.points,
    required this.compact,
    this.trendColor = ActivityTrendColor.green,
    this.onTap,
  });

  final List<double> points;
  final bool compact;
  final ActivityTrendColor trendColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final double h = compact ? 28 : 34;
    final double w = compact ? 92 : 110;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: CustomPaint(
            painter: _SparklinePainter(
              points: points.isEmpty ? const [0, 0, 0, 0] : points,
              lineColor: LeaderboardActivityTrendSparkline._getTrendColor(trendColor),
              fillColor: LeaderboardActivityTrendSparkline._getTrendColor(trendColor).withValues(alpha: 0.10),
              gridColor: cs.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
        ),
      ),
    );
  }

  static Color _getTrendColor(ActivityTrendColor color) {
    switch (color) {
      case ActivityTrendColor.green:
        return Colors.green;
      case ActivityTrendColor.red:
        return Colors.red;
      case ActivityTrendColor.blue:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<double> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    paintGrid.color = gridColor;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );

    canvas.save();
    canvas.clipRRect(r);

    // Minimal horizontal grid lines (2)
    final y1 = size.height * 0.33;
    final y2 = size.height * 0.66;
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), paintGrid);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), paintGrid);

    if (points.length < 2) {
      final p = Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height * 0.6),
        Offset(size.width, size.height * 0.6),
        p,
      );
      canvas.restore();
      return;
    }

    final double minV = points.reduce(math.min);
    final double maxV = points.reduce(math.max);
    final double range = (maxV - minV).abs() < 0.000001 ? 1 : (maxV - minV);

    final dx = size.width / (points.length - 1);

    Offset mapPoint(int i) {
      final v = points[i];
      final norm = (v - minV) / range;
      final y = size.height - (norm * size.height);
      return Offset(i * dx, y.clamp(0.0, size.height));
    }

    final path = Path()..moveTo(mapPoint(0).dx, mapPoint(0).dy);
    for (int i = 1; i < points.length; i++) {
      final p = mapPoint(i);
      path.lineTo(p.dx, p.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final paintFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(fill, paintFill);

    final paintLine = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paintLine);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}
