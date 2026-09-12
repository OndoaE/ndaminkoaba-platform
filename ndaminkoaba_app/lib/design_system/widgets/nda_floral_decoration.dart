import 'package:flutter/material.dart';

/// Textile-derived botanical artwork, oriented toward the containing corner.
/// The solid black matte is keyed out at render time; no blur or desaturation.
class NdaFloralDecoration extends StatelessWidget {
  const NdaFloralDecoration({
    super.key,
    this.corner = Alignment.topLeft,
    this.size = 220,
    this.opacity = 0.5,
    this.fadeStop = 0.55,
  });
  final Alignment corner;
  final double size;
  final double opacity;
  final double fadeStop;

  @override
  Widget build(BuildContext context) {
    final turns = corner.x > 0
        ? (corner.y < 0 ? 1 : 2)
        : (corner.y > 0 ? 3 : 0);
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Opacity(
          opacity: opacity,
          child: SizedBox.square(
            dimension: size,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                1,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
                0,
                2,
                2,
                2,
                0,
                0,
              ]),
              child: RotatedBox(
                quarterTurns: turns,
                child: Image.asset(
                  'assets/images/heritage_floral_corner.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
