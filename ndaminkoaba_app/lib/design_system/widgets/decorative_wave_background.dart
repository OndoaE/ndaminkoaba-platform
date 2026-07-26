import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Soft decorative wave shapes for the Home dashboard's cream background —
/// purely ambient texture behind the real content, not interactive.
/// Painted rather than an SVG asset so it needs no new asset file and scales
/// cleanly to any screen width.
class DecorativeWaveBackground extends StatelessWidget {
  const DecorativeWaveBackground({super.key, this.height = 220});

  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(
          painter: _WavePainter(),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final back = Paint()..color = AppColors.cardAlt;
    final backPath = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.15, size.width * 0.55, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.5, size.width, size.height * 0.28)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(backPath, back);

    final front = Paint()..color = AppColors.secondary.withValues(alpha: 0.14);
    final frontPath = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.75, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.3, size.width, size.height * 0.5)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(frontPath, front);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => false;
}
