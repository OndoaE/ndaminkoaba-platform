import 'package:flutter/material.dart';

import '../../../design_system/cards/featured_card.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/navigation/learner_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/app_header.dart';
import '../../../design_system/widgets/badge_card.dart';
import '../../../design_system/widgets/gold_corner_pattern.dart';
import '../../../design_system/widgets/progress_ring.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../design_system/widgets/streak_badge.dart';
import '../../../design_system/widgets/week_calendar.dart';
import '../../../l10n/app_localizations.dart';
import '../../badges/data/badges_repository.dart';
import '../../badges/domain/badge_entry.dart';
import '../../streaks/data/streaks_repository.dart';
import '../../streaks/domain/streak_stats.dart';
import '../data/practice_repository.dart';
import '../data/vocabulary_review_repository.dart';
import '../domain/practice_today.dart';
import 'vocabulary_review_screen.dart';

/// Tab-root "Practice" screen (bottom nav index 2) — Smart Review queue,
/// weekly activity calendar, and badge progress.
/// Entirely new screen; no equivalent existed before this redesign.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final practiceRepository = PracticeRepository();
  final reviewRepository = VocabularyReviewRepository();
  final badgesRepository = BadgesRepository();
  final streaksRepository = StreaksRepository();

  bool isLoading = true;
  bool hasError = false;
  PracticeToday? today;
  List<PracticeDay> weeklyCalendar = [];
  VocabularyReviewDue? due;
  List<BadgeEntry> badges = [];
  StreakStats? streakStats;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final results = await Future.wait([
        practiceRepository.getToday(),
        practiceRepository.getWeeklyCalendar(),
        reviewRepository.getDue(limit: 20),
        badgesRepository.getBadges(),
        streaksRepository.getMe(),
      ]);
      if (!mounted) return;
      setState(() {
        today = results[0] as PracticeToday;
        weeklyCalendar = results[1] as List<PracticeDay>;
        due = results[2] as VocabularyReviewDue;
        badges = results[3] as List<BadgeEntry>;
        streakStats = results[4] as StreakStats;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _startReview() async {
    final items = due?.items ?? [];
    if (items.isEmpty) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => VocabularyReviewScreen(items: items)),
    );
    load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nextBadge = badges.where((b) => !b.earned).isNotEmpty
        ? badges.where((b) => !b.earned).first
        : null;

    return LearnerShell(
      activeNavKey: '',
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.giant,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  title: l10n.practiceTitle,
                  subtitle: l10n.practiceSubtitle,
                  showAvatar: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (hasError)
                  PremiumCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off_outlined,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(l10n.practiceLoadError)),
                      ],
                    ),
                  )
                else if (isLoading)
                  const ShimmerListLoader(itemCount: 3, itemHeight: 100)
                else ...[
                  // Daily Practice hero
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: AppRadius.large,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Stack(
                      children: [
                        const GoldCornerPattern(color: Colors.white),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dailyPracticeTitle,
                              style: AppTypography.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              today != null
                                  ? (today!.minutesToday >= today!.goalMinutes
                                        ? l10n.dailyGoalReachedMessage
                                        : l10n.minutesToGoalMessage(
                                            today!.goalMinutes -
                                                today!.minutesToday,
                                          ))
                                  : '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                if (today != null)
                                  ProgressRing(
                                    progress: today!.progressRatio,
                                    centerLabel:
                                        '${today!.minutesToday}/${today!.goalMinutes}',
                                    subLabel: l10n.minutesUnitLabel,
                                    size: 84,
                                    strokeWidth: 8,
                                  ),
                                const SizedBox(width: AppSpacing.lg),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.white24,
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                if (streakStats != null)
                                  StreakBadge(days: streakStats!.currentStreak),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (due?.dueCount ?? 0) > 0
                                    ? _startReview
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  disabledBackgroundColor: Colors.white
                                      .withValues(alpha: 0.5),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadius.circle,
                                  ),
                                ),
                                child: Text(
                                  l10n.continuePracticeButton,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Smart Review — featured card
                  InkWell(
                    borderRadius: AppRadius.large,
                    onTap: (due?.dueCount ?? 0) > 0 ? _startReview : null,
                    child: FeaturedCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.ai.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.autorenew,
                              color: AppColors.ai,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.smartReviewTitle,
                                  style: AppTypography.title.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (due?.dueCount ?? 0) > 0
                                      ? l10n.wordsReadyForReview(due!.dueCount)
                                      : l10n.noWordsDueMessage,
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          if ((due?.dueCount ?? 0) > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.circle,
                              ),
                              child: Text(
                                l10n.reviewNowButton,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Weekly calendar
                  SectionTitle(
                    title: l10n.thisWeekTitle,
                    subtitle: l10n.practiceDaysCount(
                      weeklyCalendar.where((d) => d.completed).length,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PremiumCard(
                    child: WeekCalendar(
                      days: weeklyCalendar
                          .map(
                            (d) => WeekCalendarDay(
                              date: d.date,
                              completed: d.completed,
                              minutes: d.minutes,
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  if (nextBadge != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    FeaturedCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.badgeEarned.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.emoji_events,
                              color: AppColors.badgeEarned,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.almostThereTitle,
                                  style: AppTypography.title.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  l10n.completeSessionsForBadge(
                                    (nextBadge.criteriaValue -
                                            nextBadge.progress)
                                        .clamp(0, nextBadge.criteriaValue),
                                    nextBadge.name,
                                  ),
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  SectionTitle(title: l10n.badgesTitle),
                  const SizedBox(height: AppSpacing.lg),
                  if (badges.isEmpty)
                    Text(l10n.noBadgesYetMessage, style: AppTypography.caption)
                  else
                    ...badges.map(
                      (badge) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: BadgeCardWidget(
                          name: badge.name,
                          description: badge.description,
                          earned: badge.earned,
                          progress: badge.progress,
                          criteriaValue: badge.criteriaValue,
                          remainingLabel: (remaining) =>
                              l10n.completeMoreForBadge(remaining),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
