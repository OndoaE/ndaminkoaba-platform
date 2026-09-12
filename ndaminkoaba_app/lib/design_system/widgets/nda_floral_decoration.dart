import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The Ewondo textile ("Ewondo_tissus.jpg") as a reusable brand accent — a
/// soft floral bloom that appears to grow out of whatever surface it's
/// placed on, never a hard-edged photo rectangle.
///
/// The fabric's own background is black, which would show as a stark dark
/// square on a cream page (or wash out to near-white if simply screen-
/// blended against a light backdrop — the math there crushes every color
/// toward white). Instead this derives each pixel's opacity from its own
/// brightness via a luminance-to-alpha [ColorFilter.matrix]: black
/// background pixels resolve to fully transparent, while the fabric's
/// bright gold/red/teal threads stay visible — so only the flowers ever
/// render, regardless of what's behind them.
///
/// The reference mockups render these blooms as a soft, muted illustration
/// rather than the source photo's saturated, high-contrast print, so the
/// image is also desaturated and gently blurred before that alpha step —
/// this is the same real fabric asset throughout, processed toward that
/// softer palette, not a different image.
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

  /// Where (as a fraction of [size]) the bloom starts fading to fully
  /// transparent, measured outward from [corner]. Lower = fades sooner
  /// (smaller visible bloom); higher = the fabric stays visible closer to
  /// the widget's far edge.
  final double fadeStop;

  // Muted/pastel pass — desaturates to ~65% strength using standard luma
  // weights (kept light: a heavier pull toward gray reads as washed-out
  // rather than "softer color"). Every row's constant term is 0, so pure
  // black (0,0,0) maps to (0,0,0) exactly regardless of these weights:
  // desaturating can never lift the background off black, which the
  // alpha step below depends on.
  static const _desaturate = ColorFilter.matrix(<double>[
    0.725, 0.250, 0.025, 0, 0,
    0.075, 0.900, 0.025, 0, 0,
    0.075, 0.250, 0.675, 0, 0,
    0,     0,     0,     1, 0,
  ]);

  // Turns the (now-muted) black background transparent while keeping any
  // saturated color close to fully opaque — plain Rec.709 luma weights
  // would make the fabric's reds fade out too aggressively.
  static const _alphaFromBrightness = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0.8, 0.8, 0.8, 0, 10,
  ]);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: size,
          height: size,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: 0.5,
              sigmaY: 0.5,
              tileMode: TileMode.decal,
            ),
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => RadialGradient(
                center: corner,
                radius: 1.15,
                colors: const [Colors.white, Colors.transparent],
                stops: [fadeStop, 1.0],
              ).createShader(rect),
              child: ColorFiltered(
                colorFilter: _alphaFromBrightness,
                child: ColorFiltered(
                  colorFilter: _desaturate,
                  child: Image.asset(
                    'assets/images/Ewondo_tissus.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
