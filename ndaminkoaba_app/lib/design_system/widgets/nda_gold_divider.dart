import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// The small line-diamond-line accent under a heading (Login, the
/// dashboard's "Explore" section) — kept tiny and shared now that it's
/// used in more than one place, instead of re-hand-rolling the same Row.
class NdaGoldDivider extends StatelessWidget {
  const NdaGoldDivider({super.key, this.lineWidth = 28, this.color = AppColors.secondary});

  final double lineWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: lineWidth, height: 1, color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Transform.rotate(
            angle: 0.785398, // 45deg — a diamond, not a square
            child: Container(width: 6, height: 6, color: color),
          ),
        ),
        Container(width: lineWidth, height: 1, color: color),
      ],
    );
  }
}
