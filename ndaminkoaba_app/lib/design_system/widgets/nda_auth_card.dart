import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';

/// The elevated card Login/Register/Welcome float their form on, over an
/// [NdaPageBackground]. Extracted from the `ConstrainedBox(430)` shell
/// Login and Register used to duplicate directly on a flat background —
/// now a real floating card, matching the auth mockup.
class NdaAuthCard extends StatelessWidget {
  const NdaAuthCard({
    super.key,
    required this.child,
    this.maxWidth = 430,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.lightCream.withValues(alpha: 0.94),
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.floating,
        ),
        child: child,
      ),
    );
  }
}
