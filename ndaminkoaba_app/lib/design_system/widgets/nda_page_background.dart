import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import 'nda_floral_decoration.dart';

/// The shared page backdrop for the NdaMinkoaba brand: a cream base plus
/// one or two [NdaFloralDecoration] corner blooms, bleeding slightly past
/// the edge so they read as ambient decoration rather than a placed sticker.
/// Wrap a screen's `Scaffold.body` in this instead of hand-rolling a
/// background per screen — every screen that opts in shares one visual
/// identity, and a future palette/asset change only has to happen here.
///
/// [child] is always painted last (on top), so decoration never competes
/// with real content for taps or legibility.
class NdaPageBackground extends StatelessWidget {
  const NdaPageBackground({
    super.key,
    required this.child,
    this.corners = const [Alignment.topLeft, Alignment.bottomRight],
    this.decorationSize = 220,
    this.opacity = 0.5,
    this.tint,
  });

  final Widget child;
  final List<Alignment> corners;
  final double decorationSize;
  final double opacity;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final bleed = decorationSize * 0.15;

    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.background)),
        for (final corner in corners)
          Positioned(
            top: corner.y <= 0 ? -bleed : null,
            bottom: corner.y > 0 ? -bleed : null,
            left: corner.x <= 0 ? -bleed : null,
            right: corner.x > 0 ? -bleed : null,
            child: NdaFloralDecoration(
              corner: corner,
              size: decorationSize,
              opacity: opacity,
              tint: tint,
            ),
          ),
        child,
      ],
    );
  }
}
