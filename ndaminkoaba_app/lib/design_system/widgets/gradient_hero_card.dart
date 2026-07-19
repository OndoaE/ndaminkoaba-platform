import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';

/// The gradient-banner-with-colored-shadow container used for every screen's
/// hero section (dashboard stats, courses header, admin dashboard, quiz
/// builder header). Previously hand-rolled as a near-identical `Container`
/// in each of those screens — centralized here so they can't drift apart.
class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({
    super.key,
    required this.gradient,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderRadius,
  });

  final Gradient gradient;
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final shadowColor = gradient is LinearGradient
        ? (gradient as LinearGradient).colors.first
        : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? AppRadius.extraLarge,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}
