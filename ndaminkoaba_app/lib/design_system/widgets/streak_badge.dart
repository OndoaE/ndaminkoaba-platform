import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// "🔥 7-day streak" pill used on Home and Practice.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.streakFlame.withValues(alpha: 0.12),
        borderRadius: AppRadius.circle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.streakFlame, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$days',
            style: AppTypography.title.copyWith(color: AppColors.streakFlame, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
