import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../features/badges/domain/badge_entry.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Celebration moment shown whenever a badge-awarding action (lesson
/// completion, quiz pass, Smart Review grade, pronunciation attempt)
/// returns `newlyEarnedBadges` — reuses the trophy animation already
/// licensed for the quiz-pass moment, since "you achieved something" is the
/// same feeling in both places.
class BadgeEarnedDialog extends StatelessWidget {
  const BadgeEarnedDialog({super.key, required this.badges});

  final List<BadgeEntry> badges;

  static Future<void> show(BuildContext context, List<BadgeEntry> badges) {
    if (badges.isEmpty) return Future.value();
    return showDialog(
      context: context,
      builder: (_) => BadgeEarnedDialog(badges: badges),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Lottie.asset(
                'assets/lottie/quiz_success.json',
                fit: BoxFit.contain,
                repeat: false,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.emoji_events,
                  color: AppColors.badgeEarned,
                  size: 72,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              badges.length == 1 ? 'Badge Earned!' : '${badges.length} Badges Earned!',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ...badges.map(
              (badge) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  children: [
                    Text(
                      badge.name,
                      style: AppTypography.title.copyWith(color: AppColors.badgeEarned),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      badge.description,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                ),
                child: const Text('Nice!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
