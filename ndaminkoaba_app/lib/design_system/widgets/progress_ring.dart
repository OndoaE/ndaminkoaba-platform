import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../typography/app_typography.dart';

/// Circular daily-practice-minutes ring for the Home dashboard, e.g. "6/10
/// min". A thin custom painter rather than [CircularProgressIndicator] so
/// the track color, stroke cap, and center label can all be controlled
/// together as one cohesive piece.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.centerLabel,
    required this.subLabel,
    this.size = 96,
    this.strokeWidth = 10,
    this.foregroundColor,
    this.heritageColors = false,
  });

  final Color? foregroundColor;
  final bool heritageColors;
  final double progress;
  final String centerLabel;
  final String subLabel;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0, 1),
              heritageColors: heritageColors,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: AppTypography.numeric.copyWith(
                  color: foregroundColor,
                  fontSize: size * 0.23,
                ),
              ),
              if (subLabel.isNotEmpty)
                Text(
                  subLabel,
                  style: AppTypography.caption.copyWith(fontSize: size * 0.09),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.heritageColors,
  });

  final bool heritageColors;
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = AppColors.progressRingTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [AppColors.secondary, AppColors.primary],
        startAngle: -1.5708,
        endAngle: 4.7124,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    const startAngle = -1.5708; // -90deg, 12 o'clock
    final sweepAngle = 6.2832 * progress; // 2*pi
    if (progress <= 0) return;
    if (heritageColors) {
      const colors = [Color(0xFF009B79), Color(0xFFE30020), Color(0xFFF2BA16)];
      for (var i = 0; i < colors.length; i++) {
        final paint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + sweepAngle * i / 3,
          sweepAngle / 3,
          false,
          paint,
        );
      }
      return;
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.heritageColors != heritageColors;
}
