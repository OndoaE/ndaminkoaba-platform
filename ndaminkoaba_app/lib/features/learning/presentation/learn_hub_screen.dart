import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/featured_card.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/navigation/app_bottom_navigation.dart';
import '../../../design_system/navigation/tab_navigation.dart';
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
import '../../courses/domain/models/course_detail.dart';
import '../../practice/data/practice_repository.dart';
import '../../progress/data/progress_repository.dart';

const _kLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

String _levelBadge(String level) {
  switch (level) {
    case 'BEGINNER':
      return 'A1';
    case 'INTERMEDIATE':
      return 'B1';
    case 'ADVANCED':
      return 'C1';
    default:
      return '';
  }
}

/// Tab-root "Learn" screen (bottom nav index 1). Folds Vocabulary, Bible,
/// and Books into this hub via [_HubEntryCard]s, and — matching the
/// mockup — shows the selected level's primary course as a "Path" summary
/// plus its modules directly (rather than a list of course cards), since
/// each level currently maps to exactly one course.
class LearnHubScreen extends ConsumerStatefulWidget {
  const LearnHubScreen({super.key});

  @override
  ConsumerState<LearnHubScreen> createState() => _LearnHubScreenState();
}

class _LearnHubScreenState extends ConsumerState<LearnHubScreen> {
  final courseRepository = CourseRepository();
  final progressRepository = ProgressRepository();
  final practiceRepository = PracticeRepository();
  final searchController = TextEditingController();

  String selectedLevel = 'BEGINNER';
  String searchQuery = '';
  bool isLoading = true;
  Course? primaryCourse;
  CourseDetail? courseDetail;
  Set<String> completedLessonIds = {};
  Set<String> lockedLessonIds = {};
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

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final userId = await StorageService.getUserId();
      final languageId = ref.read(currentLearningLanguageProvider);

      final courses = await courseRepository.getCourses(level: selectedLevel, languageId: languageId);
      final course = courses.isNotEmpty ? courses.first : null;

      CourseDetail? detail;
      Set<String> completed = {};
      if (course != null) {
        detail = await courseRepository.getCourseDetail(course.id);
        if (userId != null) {
          completed = await progressRepository.getCompletedLessonIds(userId);
        }
      }

      bool metToday = false;
      try {
        final week = await practiceRepository.getWeeklyCalendar();
        metToday = week.isNotEmpty && week.last.completed;
      } catch (_) {
        // Daily-goal banner is best-effort.
      }

      if (!mounted) return;

      final locked = <String>{};
      if (detail != null) {
        final sortedModules = [...detail.modules]..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
        final orderedLessons = sortedModules
            .expand((m) => [...m.lessons]..sort((a, b) => a.orderNumber.compareTo(b.orderNumber)))
            .toList();
        for (var i = 1; i < orderedLessons.length; i++) {
          if (!completed.contains(orderedLessons[i - 1].id)) {
            locked.add(orderedLessons[i].id);
          }
        }
      }

      setState(() {
        primaryCourse = course;
        courseDetail = detail;
        completedLessonIds = completed;
        lockedLessonIds = locked;
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
    final detail = courseDetail;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) => handleTabTap(context, index),
      ),
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
                  title: 'Learn Ewondo',
                  subtitle: 'Choose a level and continue your journey.',
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: PremiumTextField(
                        hint: l10n.searchCoursesHint,
                        controller: searchController,
                        prefixIcon: Icons.search,
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
                      child: const Icon(Icons.tune, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.circle),
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
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : Colors.transparent,
                              borderRadius: AppRadius.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _CoursesLevelLabel.of(l10n, level),
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.textPrimary,
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
                else if (primaryCourse == null)
                  EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: l10n.noCoursesTitle,
                    message: l10n.noCoursesMessage,
                  )
                else ...[
                  FeaturedCard(
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Icon(Icons.route_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      localizedText(primaryCourse!.title, primaryCourse!.frenchTitle, isFrench),
                                      style: AppTypography.title.copyWith(color: AppColors.primary),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.15),
                                      borderRadius: AppRadius.circle,
                                    ),
                                    child: Text(
                                      _levelBadge(selectedLevel),
                                      style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                localizedText(primaryCourse!.description, primaryCourse!.frenchDescription, isFrench),
                                style: AppTypography.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              if (detail != null) ...[
                                Text(
                                  '${completedLessonIds.where((id) => detail.modules.any((m) => m.lessons.any((l) => l.id == id))).length} of ${detail.lessonCount} lessons',
                                  style: AppTypography.caption,
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: detail.lessonCount == 0
                                        ? 0
                                        : completedLessonIds
                                                .where((id) => detail.modules.any((m) => m.lessons.any((l) => l.id == id)))
                                                .length /
                                            detail.lessonCount,
                                    minHeight: 6,
                                    backgroundColor: AppColors.progressRingTrack,
                                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionTitle(title: l10n.modulesTitle, subtitle: l10n.modulesSubtitle),
                  const SizedBox(height: AppSpacing.lg),
                  if (detail != null)
                    ...([...detail.modules]..sort((a, b) => a.orderNumber.compareTo(b.orderNumber))).asMap().entries.map(
                          (entry) => _ModuleCard(
                            courseId: primaryCourse!.id,
                            index: entry.key,
                            module: entry.value,
                            completedLessonIds: completedLessonIds,
                            lockedLessonIds: lockedLessonIds,
                            isFrench: isFrench,
                          ),
                        ),
                ],

                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: AppRadius.large),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Stack(
                    children: [
                      const GoldCornerPattern(color: Colors.white, size: 48),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: const Icon(Icons.local_fire_department, color: Colors.white),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Goal', style: AppTypography.title.copyWith(color: Colors.white)),
                                Text('Complete 1 lesson today', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            dailyGoalMetToday ? '1/1' : '0/1',
                            style: AppTypography.h2.copyWith(color: Colors.white),
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.courseId,
    required this.index,
    required this.module,
    required this.completedLessonIds,
    required this.lockedLessonIds,
    required this.isFrench,
  });

  final String courseId;
  final int index;
  final CourseDetailModule module;
  final Set<String> completedLessonIds;
  final Set<String> lockedLessonIds;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final sortedLessons = [...module.lessons]..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    final completedCount = sortedLessons.where((l) => completedLessonIds.contains(l.id)).length;
    final isLocked = sortedLessons.isNotEmpty && lockedLessonIds.contains(sortedLessons.first.id);
    final isComplete = sortedLessons.isNotEmpty && completedCount == sortedLessons.length;
    final nextLesson = sortedLessons.firstWhere(
      (l) => !completedLessonIds.contains(l.id),
      orElse: () => sortedLessons.isNotEmpty ? sortedLessons.first : sortedLessons.first,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Opacity(
        opacity: isLocked ? 0.6 : 1,
        child: PremiumCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.success
                      : isLocked
                          ? AppColors.textSecondary.withValues(alpha: 0.3)
                          : AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : isLocked
                        ? const Icon(Icons.lock_outline, color: Colors.white, size: 16)
                        : Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizedText(module.title, module.frenchTitle, isFrench), style: AppTypography.title.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      isLocked
                          ? 'Complete Module $index to unlock'
                          : '${sortedLessons.length} lessons • $completedCount completed',
                      style: AppTypography.caption,
                    ),
                    if (!isLocked && sortedLessons.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: completedCount / sortedLessons.length,
                          minHeight: 5,
                          backgroundColor: AppColors.progressRingTrack,
                          valueColor: AlwaysStoppedAnimation(isComplete ? AppColors.success : AppColors.secondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!isLocked && sortedLessons.isNotEmpty)
                OutlinedButton(
                  onPressed: () => context.push('/courses/$courseId/lessons/${(isComplete ? sortedLessons.first : nextLesson).id}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isComplete ? AppColors.primary : Colors.white,
                    backgroundColor: isComplete ? Colors.transparent : AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.circle),
                  ),
                  child: Text(isComplete ? 'REVIEW' : 'CONTINUE', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                )
              else if (isLocked)
                const Icon(Icons.lock, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
