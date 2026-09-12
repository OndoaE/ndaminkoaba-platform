import 'package:flutter/material.dart';

/// The Ewondo textile ("Ewondo_tissus.jpg") as a reusable brand accent — a
/// soft corner bloom, never a hard-edged rectangle. The image fades to
/// transparent away from [corner] via a radial [ShaderMask] so it can sit
/// behind real content without ever reading as "a photo was pasted here."
///
/// Pass [tint] to darken/recolor the fabric (its native background is
/// black with bright gold/red/teal embroidery) so it recedes into a dark
/// surface — e.g. the green sidebar — instead of clashing with it.
class NdaFloralDecoration extends StatelessWidget {
  const NdaFloralDecoration({
    super.key,
    this.corner = Alignment.topLeft,
    this.size = 220,
    this.opacity = 0.5,
    this.tint,
  });

  final Alignment corner;
  final double size;
  final double opacity;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      'assets/images/Ewondo_tissus.jpg',
      fit: BoxFit.cover,
    );

    if (tint != null) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(tint!, BlendMode.modulate),
        child: image,
      );
    }

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: size,
          height: size,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => RadialGradient(
              center: corner,
              radius: 1.0,
              colors: const [Colors.white, Colors.transparent],
              stops: const [0.25, 1.0],
            ).createShader(rect),
            child: image,
          ),
        ),
      ),
    );
  }
}
