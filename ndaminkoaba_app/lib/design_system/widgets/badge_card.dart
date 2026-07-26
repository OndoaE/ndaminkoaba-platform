import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import '../cards/premium_card.dart';

/// A single achievement badge, locked or earned, with a "X more to go"
/// progress line for the Practice screen's badge list.
class BadgeCardWidget extends StatelessWidget {
  const BadgeCardWidget({
    super.key,
    required this.name,
    required this.description,
    required this.earned,
    required this.progress,
    required this.criteriaValue,
    required this.remainingLabel,
  });

  final String name;
  final String description;
  final bool earned;
  final int progress;
  final int criteriaValue;
  final String Function(int remaining) remainingLabel;

  @override
  Widget build(BuildContext context) {
    final remaining = (criteriaValue - progress).clamp(0, criteriaValue);
    final ratio = criteriaValue > 0 ? progress / criteriaValue : 0.0;

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: earned ? AppColors.badgeEarned.withValues(alpha: 0.15) : AppColors.badgeLocked.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              earned ? Icons.emoji_events : Icons.emoji_events_outlined,
              color: earned ? AppColors.badgeEarned : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.title.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  earned ? description : remainingLabel(remaining),
                  style: AppTypography.caption,
                ),
                if (!earned) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: AppRadius.small,
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0, 1),
                      minHeight: 5,
                      backgroundColor: AppColors.progressRingTrack,
                      valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
