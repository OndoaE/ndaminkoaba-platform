import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Standard "nothing here" / "not found" treatment — an icon-in-circle (or,
/// for a handful of high-visibility screens, a small animated illustration),
/// title, caption and optional action — replacing the bare centered `Text`
/// that most screens used to fall back to.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconColor = AppColors.primary,
    this.lottieAsset,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color iconColor;

  /// Optional path under `assets/lottie/` — when set, replaces the static
  /// icon-in-circle with a small looping animation instead. Reserved for
  /// screens where the extra warmth earns its keep (Books, Bible); most
  /// empty states are fine with the plain icon.
  final String? lottieAsset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lottieAsset != null)
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  lottieAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => _IconCircle(
                    icon: icon,
                    iconColor: iconColor,
                  ),
                ),
              )
            else
              _IconCircle(icon: icon, iconColor: iconColor),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.title,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  message!,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.iconColor});

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 32),
    );
  }
}
