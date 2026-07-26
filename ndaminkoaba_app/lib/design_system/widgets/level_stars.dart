import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

/// Row of stars indicating a course level (1=Beginner, 2=Intermediate,
/// 3=Advanced) — always gold regardless of the surrounding certificate theme.
class LevelStars extends StatelessWidget {
  const LevelStars({
    super.key,
    required this.count,
    this.size = 18,
    this.color = AppColors.secondary,
  });

  final int count;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
            child: Icon(Icons.star, color: color, size: size),
          ),
      ],
    );
  }
}
