import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../widgets/gold_corner_pattern.dart';

/// Gold-bordered cream card used for "featured" moments — Beginner Path,
/// Smart Review, the Nnanga AI Tutor banner, the Daily Goal strip — as
/// distinct from the plain white [PremiumCard] used for regular content.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.showCornerPattern = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool showCornerPattern;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          if (showCornerPattern) const GoldCornerPattern(),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
