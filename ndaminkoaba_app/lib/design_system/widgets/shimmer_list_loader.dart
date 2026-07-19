import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';

/// A skeleton-card shimmer used while admin lists load, instead of a bare
/// spinner — reads as "content is coming" rather than "something is stuck".
class ShimmerListLoader extends StatelessWidget {
  const ShimmerListLoader({super.key, this.itemCount = 4, this.itemHeight = 84});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: itemHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
