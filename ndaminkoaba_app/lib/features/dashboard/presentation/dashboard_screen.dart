import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/locale/localized_text.dart';
import '../../courses/data/enrollment_repository.dart';
import '../../courses/domain/models/enrolled_course.dart';
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

IconData _levelIcon(String level) {
  switch (level) {
    case 'BEGINNER':
      return Icons.looks_one_outlined;
    case 'INTERMEDIATE':
      return Icons.looks_two_outlined;
    case 'ADVANCED':
      return Icons.looks_3_outlined;
    default:
      return Icons.menu_book_outlined;
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

  bool isLoading = true;
  String fullName = '';
  DashboardStats? stats;
  EnrolledCourse? continueCourse;
  DailyWord? dailyWord;
  DailyVerse? dailyVerse;

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
    });

    // Daily word/verse are shown regardless of whether the rest of the
    // dashboard loads, so fetch them independently of the userId-gated
    // stats/enrollments below.
    unawaited(_loadDailyContent());

    if (userId == null || userId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        dashboardRepository.getLearnerDashboard(userId),
        enrollmentRepository.getMyEnrollments(userId),
      ]);

      if (!mounted) return;

      final enrollments = results[1] as List<EnrolledCourse>;
      final active = enrollments.where((e) => e.status == 'ACTIVE');

      setState(() {
        stats = results[0] as DashboardStats;
        continueCourse = active.isNotEmpty ? active.first : null;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
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
    final initial = greetingName.isNotEmpty
        ? greetingName[0].toUpperCase()
        : 'L';

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
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greetingName 👋',
                            style: AppTypography.h2.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            l10n.dashboardSubtitle,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isLoading)
                  const ShimmerListLoader(itemCount: 1, itemHeight: 80)
                else
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.check_circle_outline,
                          value: '${stats?.completedLessons ?? 0}',
                          label: l10n.statLessons,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.workspace_premium_outlined,
                          value: '${stats?.certificates ?? 0}',
                          label: l10n.statCertificates,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.percent,
                          value:
                              '${(stats?.averageQuizScore ?? 0).toStringAsFixed(0)}%',
                          label: l10n.statAvgScore,
                          color: const Color(0xFF3D6BE0),
                        ),
                      ),
                    ],
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
                SectionTitle(
                  title: l10n.quickActionsTitle,
                  subtitle: l10n.quickActionsSubtitle,
                ),
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
                    children: [
                      _ActionCard(
                        icon: Icons.menu_book,
                        title: l10n.actionCourses,
                        color: AppColors.primary,
                        onTap: () => context.push('/courses'),
                      ),
                      _ActionCard(
                        icon: Icons.translate,
                        title: l10n.actionVocabulary,
                        color: AppColors.ai,
                        onTap: () => context.push('/vocabulary'),
                      ),
                      _ActionCard(
                        icon: Icons.smart_toy,
                        customIcon: ClipOval(
                          child: Image.asset(
                            'assets/icons/nnanga_ai_icon_circle.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: l10n.actionNnanga,
                        color: const Color(0xFF3D6BE0),
                        onTap: () => context.push('/nnanga'),
                      ),
                      _ActionCard(
                        icon: Icons.workspace_premium,
                        title: l10n.actionCertificates,
                        color: AppColors.secondary,
                        onTap: () => context.push('/certificates'),
                      ),
                      _ActionCard(
                        icon: Icons.auto_stories,
                        title: l10n.actionBible,
                        color: const Color(0xFF8B3A3A),
                        onTap: () => context.push('/bible'),
                      ),
                      _ActionCard(
                        icon: Icons.local_library,
                        title: l10n.actionBooks,
                        color: const Color(0xFF5D4037),
                        onTap: () => context.push('/books'),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.xl),
                SectionTitle(
                  title: l10n.dailyWordTitle,
                  subtitle: l10n.dailyWordSubtitle,
                ),
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
                          Icons.auto_awesome,
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
                              style: AppTypography.h2,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              dailyWord == null
                                  ? l10n.dailyWordMeaning
                                  : (isFrench ? dailyWord!.frenchMeaning : dailyWord!.englishMeaning) ??
                                      l10n.bibleTranslationPending,
                              style: AppTypography.caption,
                            ),
                            if (dailyWord == null ||
                                (dailyWord!.usageHint != null && dailyWord!.usageHint!.isNotEmpty)) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                dailyWord?.usageHint ?? l10n.dailyWordUsageHint,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ],
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
                                color: const Color(0xFF8B3A3A).withValues(alpha: 0.12),
                                borderRadius: AppRadius.medium,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.auto_stories, color: Color(0xFF8B3A3A)),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(l10n.dailyContentEmpty, style: AppTypography.caption),
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
                                color: const Color(0xFF8B3A3A).withValues(alpha: 0.12),
                                borderRadius: AppRadius.medium,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.auto_stories, color: Color(0xFF8B3A3A)),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dailyVerse!.text,
                                    style: AppTypography.body.copyWith(height: 1.5, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    (isFrench ? dailyVerse!.frenchText : dailyVerse!.englishText) ??
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.medium,
            ),
            alignment: Alignment.center,
            child: Icon(_levelIcon(course.level), color: Colors.white),
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
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: course.progress / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.progressPercentLabel(course.progress),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
    this.customIcon,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  /// Overrides [icon] with a custom badge/logo image when provided (e.g.
  /// the Nnanga AI badge), instead of a plain Material glyph.
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: PremiumCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: customIcon ?? Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
