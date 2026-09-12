import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import 'nda_floral_decoration.dart';

/// The shared page backdrop for the NdaMinkoaba brand: a cream base plus
/// [NdaFloralDecoration] corner blooms, bleeding slightly past the edge so
/// they read as ambient decoration rather than a placed sticker. Wrap a
/// screen's `Scaffold.body` in this instead of hand-rolling a background
/// per screen — every screen that opts in shares one visual identity, and
/// a future palette/asset change only has to happen here.
///
/// [corners] get full [opacity]; [faintCorners] get a quarter of it — use
/// this on auth screens to match the reference's strong top-left/
/// bottom-right blooms with barely-there accents on the other two corners,
/// while every other screen just passes [corners] and leaves the rest to
/// its (subtler) defaults.
///
/// [child] is always painted last (on top), so decoration never competes
/// with real content for taps or legibility.
class NdaPageBackground extends StatelessWidget {
  const NdaPageBackground({
    super.key,
    required this.child,
    this.corners = const [Alignment.topLeft, Alignment.bottomRight],
    this.faintCorners = const [],
    this.decorationSize = 420,
    this.opacity = 0.14,
    this.fadeStop = 0.4,
    this.backgroundColor = AppColors.background,
  });

  final Widget child;
  final List<Alignment> corners;
  final List<Alignment> faintCorners;
  final double decorationSize;
  final double opacity;
  final double fadeStop;
  final Color backgroundColor;

  Widget _bloom(Alignment corner, double blendOpacity, double size) {
    final bleed = size * 0.035;
    return Positioned(
      top: corner.y <= 0 ? -bleed : null,
      bottom: corner.y > 0 ? -bleed : null,
      left: corner.x <= 0 ? -bleed : null,
      right: corner.x > 0 ? -bleed : null,
      child: NdaFloralDecoration(
        corner: corner,
        size: size,
        opacity: blendOpacity,
        fadeStop: fadeStop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final effectiveSize = narrow
        ? decorationSize.clamp(0.0, 280.0)
        : decorationSize;
    final effectiveOpacity = narrow && opacity <= 0.2 ? opacity * 0.5 : opacity;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: backgroundColor)),
        for (final corner in corners)
          _bloom(corner, effectiveOpacity, effectiveSize),
        // Faint corners are a smaller, much dimmer accent — never a
        // second full-size bloom — so two corners always stay properly
        // clean rather than the page reading as flowers-on-all-sides.
        for (final corner in faintCorners)
          _bloom(corner, effectiveOpacity * 0.15, effectiveSize * 0.65),
        child,
      ],
    );
  }
}
