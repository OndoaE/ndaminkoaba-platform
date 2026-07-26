import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Small repeating diamond/key motif painted in a card's corner — the
/// decorative accent seen on the mockups' featured cards (hero cards,
/// Beginner Path, Smart Review, Nnanga banner). Purely ambient; not
/// interactive.
class GoldCornerPattern extends StatelessWidget {
  const GoldCornerPattern({
    super.key,
    this.size = 64,
    this.color,
    this.alignment = Alignment.bottomRight,
  });

  final double size;
  final Color? color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CornerPatternPainter(color: color ?? AppColors.secondary),
          ),
        ),
      ),
    );
  }
}

class _CornerPatternPainter extends CustomPainter {
  _CornerPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const step = 12.0;
    for (double d = step; d < size.width + size.height; d += step) {
      final path = Path();
      final start = Offset((size.width - d).clamp(0, size.width), size.height);
      final end = Offset(size.width, (size.height - d).clamp(0, size.height));
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPatternPainter oldDelegate) => oldDelegate.color != color;
}
