import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/navigation/learner_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/app_header.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gold_corner_pattern.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/domain/models/course.dart';
import '../../courses/presentation/courses_screen.dart'
    show CourseCard, previousLevel, levelLabel;
import '../../practice/data/practice_repository.dart';

const _kLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

/// Tab-root "Learn" screen (bottom nav index 1). Lists every published
/// course at the selected level as a card — a level can (and for Ewondo,
/// does) map to several courses, so each one links out to the full
/// [CourseDetailScreen] for its own modules/lessons rather than trying to
/// inline every course's content on this one screen.
class LearnHubScreen extends ConsumerStatefulWidget {
  const LearnHubScreen({super.key});

  @override
  ConsumerState<LearnHubScreen> createState() => _LearnHubScreenState();
}

class _LearnHubScreenState extends ConsumerState<LearnHubScreen> {
  final courseRepository = CourseRepository();
  final practiceRepository = PracticeRepository();
  final searchController = TextEditingController();

  String selectedLevel = 'BEGINNER';
  String searchQuery = '';
  bool isLoading = true;
  List<Course> courses = [];
  Set<String> unlockedLevels = {'BEGINNER'};
  bool dailyGoalMetToday = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Course> get _visibleCourses {
    if (searchQuery.isEmpty) return courses;
    final query = searchQuery.toLowerCase();
    return courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(query) ||
              (course.frenchTitle?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  void _showLevelLocked(String level) {
    final l10n = AppLocalizations.of(context);
    final previous = previousLevel(level);
    if (previous == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.levelLockedMessage(levelLabel(l10n, previous))),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final userId = await StorageService.getUserId();
      final languageId = ref.read(currentLearningLanguageProvider);

      final results = await Future.wait([
        courseRepository.getCourses(
          level: selectedLevel,
          languageId: languageId,
        ),
        if (userId != null)
          courseRepository.getUnlockedLevels(userId, languageId: languageId),
      ]);

      bool metToday = false;
      try {
        final week = await practiceRepository.getWeeklyCalendar();
        metToday = week.isNotEmpty && week.last.completed;
      } catch (_) {
        // Daily-goal banner is best-effort.
      }

      if (!mounted) return;

      setState(() {
        courses = results[0] as List<Course>;
        if (userId != null) {
          unlockedLevels = results[1] as Set<String>;
        }
        dailyGoalMetToday = metToday;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

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
                  onBack: () => context.go('/dashboard'),
                  title: l10n.learnHubTitle,
                  subtitle: l10n.learnHubSubtitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: PremiumTextField(
                        hint: l10n.searchCoursesHint,
                        controller: searchController,
                        prefixIcon: Icons.search,
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.medium,
                      ),
                      child: const Icon(Icons.tune, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  borderRadius: AppRadius.medium,
                  onTap: () => context.push('/syllabary'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ai.withValues(alpha: 0.08),
                      borderRadius: AppRadius.medium,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.grid_view_outlined, color: AppColors.ai),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Alphabet', style: AppTypography.title),
                              Text(
                                'Browse syllables by letter',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.ai),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.circle,
                  ),
                  child: Row(
                    children: _kLevels.map((level) {
                      final selected = selectedLevel == level;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedLevel = level);
                            load();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: AppRadius.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _CoursesLevelLabel.of(l10n, level),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                if (isLoading)
                  const ShimmerListLoader(itemCount: 3, itemHeight: 108)
                else if (_visibleCourses.isEmpty)
                  EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: l10n.noCoursesTitle,
                    message: l10n.noCoursesMessage,
                  )
                else ...[
                  SectionTitle(
                    title: l10n.availableCoursesTitle,
                    subtitle: l10n.availableCoursesSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ..._visibleCourses.map((course) {
                    final locked = !unlockedLevels.contains(course.level);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: locked
                            ? () => _showLevelLocked(course.level)
                            : () => context.push('/courses/${course.id}'),
                        child: CourseCard(
                          course: course,
                          locked: locked,
                          isFrench: isFrench,
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: AppRadius.large,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Stack(
                    children: [
                      const GoldCornerPattern(color: Colors.white, size: 48),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dailyGoalTitle,
                                  style: AppTypography.title.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  l10n.dailyGoalSubtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            dailyGoalMetToday ? '1/1' : '0/1',
                            style: AppTypography.h2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _CoursesLevelLabel {
  static String of(AppLocalizations l10n, String level) {
    switch (level) {
      case 'BEGINNER':
        return l10n.levelBeginner;
      case 'INTERMEDIATE':
        return l10n.levelIntermediate;
      case 'ADVANCED':
        return l10n.levelAdvanced;
      default:
        return level;
    }
  }
}
