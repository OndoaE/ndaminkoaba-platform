import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import 'gold_corner_pattern.dart';

/// Stat card used across the admin dashboards — icon-in-circle, a big
/// number, a label, and an optional small delta line ("+12.5%"), with the
/// same gold corner-pattern decoration used on the learner featured cards.
class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.delta,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? delta;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          const Positioned(top: 0, right: 0, child: GoldCornerPattern(size: 40)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(value, style: AppTypography.h1.copyWith(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: AppTypography.caption),
              if (delta != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  delta!,
                  style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
