import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/app_header.dart';
import '../../../design_system/cards/featured_card.dart';
import '../../../design_system/widgets/gold_corner_pattern.dart';
import '../../../design_system/widgets/progress_ring.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../design_system/widgets/streak_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/locale/localized_text.dart';
import '../../courses/data/enrollment_repository.dart';
import '../../courses/domain/models/enrolled_course.dart';
import '../../streaks/data/streaks_repository.dart';
import '../../streaks/domain/streak_stats.dart';
import '../data/dashboard_repository.dart';
import '../domain/daily_content.dart';
import '../domain/dashboard_stats.dart';

Color _levelColor(String level) {
  switch (level) {
    case 'BEGINNER':
      return AppColors.primary;
    case 'INTERMEDIATE':
      return AppColors.secondary;
    case 'ADVANCED':
      return const Color(0xFF3D6BE0);
    default:
      return AppColors.primary;
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final dashboardRepository = DashboardRepository();
  final enrollmentRepository = EnrollmentRepository();
  final streaksRepository = StreaksRepository();

  bool isLoading = true;
  bool hasError = false;
  String fullName = '';
  DashboardStats? stats;
  EnrolledCourse? continueCourse;
  DailyWord? dailyWord;
  DailyVerse? dailyVerse;
  StreakStats? streakStats;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final userId = await StorageService.getUserId();
    final storedFullName = await StorageService.getFullName();

    if (!mounted) return;

    setState(() {
      fullName = storedFullName ?? '';
      hasError = false;
    });

    unawaited(_loadDailyContent());

    if (userId == null || userId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        dashboardRepository.getLearnerDashboard(userId),
        enrollmentRepository.getMyEnrollments(userId),
        streaksRepository.getMe(),
      ]);

      if (!mounted) return;

      final enrollments = results[1] as List<EnrolledCourse>;
      final active = enrollments.where((e) => e.status == 'ACTIVE');

      setState(() {
        stats = results[0] as DashboardStats;
        continueCourse = active.isNotEmpty ? active.first : null;
        streakStats = results[2] as StreakStats;
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

  Future<void> _loadDailyContent() async {
    final languageId = ref.read(currentLearningLanguageProvider);
    try {
      final results = await Future.wait([
        dashboardRepository.getDailyWord(languageId: languageId),
        dashboardRepository.getDailyVerse(languageId: languageId),
      ]);
      if (!mounted) return;
      setState(() {
        dailyWord = results[0] as DailyWord?;
        dailyVerse = results[1] as DailyVerse?;
      });
    } catch (_) {
      // Daily content is a nice-to-have on the dashboard — silently skip
      // it rather than blocking the rest of the screen from loading.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';
    final greetingName = fullName.isNotEmpty
        ? fullName
        : l10n.dashboardFallbackName;
    final courseProgress = continueCourse?.progress ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        onTap: (index) => handleTabTap(context, index),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDashboard,
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
                  title: l10n.appTitle,
                  subtitle: l10n.appTagline,
                  showAvatar: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Mbolo, $greetingName 👋',
                  style: AppTypography.h1.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(l10n.dashboardSubtitle, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xl),

                if (hasError) ...[
                  PremiumCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off_outlined,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.commonSomethingWrong,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                if (isLoading)
                  const ShimmerListLoader(itemCount: 1, itemHeight: 160)
                else
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
                              l10n.dashboardProgressTitle,
                              style: AppTypography.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                ProgressRing(
                                  progress: courseProgress / 100,
                                  centerLabel: '$courseProgress%',
                                  subLabel: '',
                                  size: 84,
                                  strokeWidth: 8,
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.lessonsCompletedCount(
                                          stats?.completedLessons ?? 0,
                                        ),
                                        style: AppTypography.title.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Container(
                                        height: 1,
                                        color: Colors.white24,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      if (streakStats != null)
                                        StreakBadge(
                                          days: streakStats!.currentStreak,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (continueCourse != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SectionTitle(title: l10n.continueLearningTitle),
                  const SizedBox(height: AppSpacing.lg),
                  InkWell(
                    borderRadius: AppRadius.large,
                    onTap: () =>
                        context.push('/courses/${continueCourse!.courseId}'),
                    child: _ContinueLearningCard(
                      course: continueCourse!,
                      isFrench: isFrench,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
                SectionTitle(title: l10n.exploreSectionTitle),
                const SizedBox(height: AppSpacing.lg),
                if (isLoading)
                  const ShimmerListLoader(itemCount: 2, itemHeight: 160)
                else
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 2.6,
                    children: [
                      _ExploreTile(
                        icon: Icons.translate,
                        label: l10n.actionVocabulary,
                        onTap: () => context.push('/vocabulary'),
                      ),
                      _ExploreTile(
                        icon: Icons.menu_book,
                        label: l10n.navLearn,
                        onTap: () => context.push('/learn'),
                      ),
                      _ExploreTile(
                        icon: Icons.auto_stories,
                        label: l10n.actionBible,
                        onTap: () => context.push('/bible'),
                      ),
                      _ExploreTile(
                        icon: Icons.local_library,
                        label: l10n.actionBooks,
                        onTap: () => context.push('/books'),
                      ),
                    ],
                  ),

                const SizedBox(height: AppSpacing.xl),
                InkWell(
                  borderRadius: AppRadius.large,
                  onTap: () => context.push('/nnanga'),
                  child: FeaturedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/icons/nnanga_ai_icon_circle.png',
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.nnangaTitle,
                                    style: AppTypography.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    l10n.nnangaPromoSubtitle,
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadius.circle,
                            ),
                            child: Text(
                              l10n.startPracticeButton,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                SectionTitle(title: l10n.phraseOfDayTitle),
                const SizedBox(height: AppSpacing.lg),
                PremiumCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.medium,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.wb_sunny_outlined,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dailyWord?.word ?? 'Mbɔ́',
                              style: AppTypography.h2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              dailyWord == null
                                  ? l10n.dailyWordMeaning
                                  : (isFrench
                                            ? dailyWord!.frenchMeaning
                                            : dailyWord!.englishMeaning) ??
                                        l10n.bibleTranslationPending,
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                SectionTitle(
                  title: l10n.dailyVerseTitle,
                  subtitle: l10n.dailyVerseSubtitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                PremiumCard(
                  child: dailyVerse == null
                      ? Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8B3A3A,
                                ).withValues(alpha: 0.12),
                                borderRadius: AppRadius.medium,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.auto_stories,
                                color: Color(0xFF8B3A3A),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                l10n.dailyContentEmpty,
                                style: AppTypography.caption,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8B3A3A,
                                ).withValues(alpha: 0.12),
                                borderRadius: AppRadius.medium,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.auto_stories,
                                color: Color(0xFF8B3A3A),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dailyVerse!.text,
                                    style: AppTypography.body.copyWith(
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    (isFrench
                                            ? dailyVerse!.frenchText
                                            : dailyVerse!.englishText) ??
                                        l10n.bibleTranslationPending,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    dailyVerse!.reference,
                                    style: AppTypography.caption.copyWith(
                                      color: const Color(0xFF8B3A3A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.course, required this.isFrench});

  final EnrolledCourse course;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _levelColor(course.level);

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.medium,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.menu_book, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedText(course.title, course.frenchTitle, isFrench),
                  style: AppTypography.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.lessonNumberLabel(
                    (course.progress / 100 * 10).clamp(1, 999).round(),
                  ),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: course.progress / 100,
                          minHeight: 6,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l10n.progressPercentLabel(course.progress),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
              l10n.continueButton.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.medium,
      onTap: onTap,
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
