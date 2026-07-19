import 'package:flutter/material.dart';

/// The real, four-color Google "G" mark — Google's brand guidelines for
/// "Sign in with Google" buttons call for this exact logo, not a stylized
/// "G" letter. Painted from the mark's official 18x18 path data rather than
/// shipped as an image asset, so it stays crisp at any button size.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 18;
    canvas.save();
    canvas.scale(scale);

    final blue = Path()
      ..moveTo(17.64, 9.20455)
      ..cubicTo(17.64, 8.56636, 17.5827, 7.95268, 17.4764, 7.36364)
      ..lineTo(9, 7.36364)
      ..lineTo(9, 10.845)
      ..lineTo(13.8436, 10.845)
      ..cubicTo(13.635, 11.97, 13.0009, 12.9231, 12.0477, 13.5614)
      ..lineTo(12.0477, 15.8195)
      ..lineTo(14.9564, 15.8195)
      ..cubicTo(16.6582, 14.2527, 17.64, 11.9455, 17.64, 9.20455)
      ..close();
    canvas.drawPath(blue, Paint()..color = const Color(0xFF4285F4));

    final green = Path()
      ..moveTo(9, 18)
      ..cubicTo(11.43, 18, 13.4673, 17.1941, 14.9564, 15.8195)
      ..lineTo(12.0477, 13.5614)
      ..cubicTo(11.2418, 14.1014, 10.2109, 14.4205, 9, 14.4205)
      ..cubicTo(6.65591, 14.4205, 4.67182, 12.8373, 3.96409, 10.71)
      ..lineTo(0.957273, 10.71)
      ..lineTo(0.957273, 13.0418)
      ..cubicTo(2.43818, 15.9832, 5.48182, 18, 9, 18)
      ..close();
    canvas.drawPath(green, Paint()..color = const Color(0xFF34A853));

    final yellow = Path()
      ..moveTo(3.96409, 10.71)
      ..cubicTo(3.78409, 10.17, 3.68182, 9.59318, 3.68182, 9)
      ..cubicTo(3.68182, 8.40682, 3.78409, 7.83, 3.96409, 7.29)
      ..lineTo(3.96409, 4.95818)
      ..lineTo(0.957273, 4.95818)
      ..cubicTo(0.347727, 6.17318, 0, 7.54773, 0, 9)
      ..cubicTo(0, 10.4523, 0.347727, 11.8268, 0.957273, 13.0418)
      ..lineTo(3.96409, 10.71)
      ..close();
    canvas.drawPath(yellow, Paint()..color = const Color(0xFFFBBC05));

    final red = Path()
      ..moveTo(9, 3.57955)
      ..cubicTo(10.3214, 3.57955, 11.5077, 4.03364, 12.4405, 4.92545)
      ..lineTo(15.0218, 2.34409)
      ..cubicTo(13.4632, 0.891818, 11.4259, 0, 9, 0)
      ..cubicTo(5.48182, 0, 2.43818, 2.01682, 0.957273, 4.95818)
      ..lineTo(3.96409, 7.29)
      ..cubicTo(4.67182, 5.16273, 6.65591, 3.57955, 9, 3.57955)
      ..close();
    canvas.drawPath(red, Paint()..color = const Color(0xFFEA4335));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
