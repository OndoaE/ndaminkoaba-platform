import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/learner_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/app_header.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/data/course_repository.dart';
import '../../courses/domain/models/course.dart';
import '../../progress/data/progress_repository.dart';
import '../data/lesson_repository.dart';
import '../domain/lesson.dart';

const _kLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

/// "Leçons" sidebar screen — a flat, cross-module view of every lesson in
/// a course (course/level pickers + a horizontal card row on the left, a
/// detail/preview pane on the right), separate from [CourseDetailScreen]'s
/// module-by-module accordion view. "Commencer la leçon" navigates to the
/// existing, unchanged [LessonScreen].
class LessonsHubScreen extends ConsumerStatefulWidget {
  const LessonsHubScreen({super.key});

  @override
  ConsumerState<LessonsHubScreen> createState() => _LessonsHubScreenState();
}

class _LessonsHubScreenState extends ConsumerState<LessonsHubScreen> {
  final courseRepository = CourseRepository();
  final lessonRepository = LessonRepository();
  final progressRepository = ProgressRepository();

  bool isLoadingCourses = true;
  bool isLoadingLessons = false;
  String selectedLevel = 'BEGINNER';
  List<Course> courses = [];
  Course? selectedCourse;
  List<Lesson> lessons = [];
  Lesson? selectedLesson;
  Set<String> completedLessonIds = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => isLoadingCourses = true);
    try {
      final languageId = ref.read(currentLearningLanguageProvider);
      final userId = await StorageService.getUserId();
      final results = await Future.wait([
        courseRepository.getCourses(level: selectedLevel, languageId: languageId),
        if (userId != null) progressRepository.getCompletedLessonIds(userId),
      ]);
      if (!mounted) return;
      final fetchedCourses = results[0] as List<Course>;
      setState(() {
        courses = fetchedCourses;
        if (userId != null) completedLessonIds = results[1] as Set<String>;
        isLoadingCourses = false;
      });
      if (fetchedCourses.isNotEmpty) {
        _selectCourse(fetchedCourses.first);
      } else {
        setState(() {
          selectedCourse = null;
          lessons = [];
          selectedLesson = null;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingCourses = false);
    }
  }

  Future<void> _selectCourse(Course course) async {
    setState(() {
      selectedCourse = course;
      isLoadingLessons = true;
      selectedLesson = null;
    });
    try {
      final fetchedLessons = await lessonRepository.getLessonsByCourse(course.id);
      fetchedLessons.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
      if (!mounted) return;
      setState(() {
        lessons = fetchedLessons;
        selectedLesson = fetchedLessons.isNotEmpty ? fetchedLessons.first : null;
        isLoadingLessons = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingLessons = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

    return LearnerShell(
      activeNavKey: 'lessons',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(title: l10n.lessonsHubTitle, subtitle: l10n.lessonsHubSubtitle),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 760;
                    final left = _LeftPane(
                      isLoadingCourses: isLoadingCourses,
                      isLoadingLessons: isLoadingLessons,
                      courses: courses,
                      selectedCourse: selectedCourse,
                      selectedLevel: selectedLevel,
                      lessons: lessons,
                      selectedLesson: selectedLesson,
                      completedLessonIds: completedLessonIds,
                      isFrench: isFrench,
                      onLevelChanged: (level) {
                        setState(() => selectedLevel = level);
                        _loadCourses();
                      },
                      onCourseChanged: _selectCourse,
                      onLessonSelected: (lesson) => setState(() => selectedLesson = lesson),
                    );
                    final right = _DetailPane(
                      lesson: selectedLesson,
                      course: selectedCourse,
                      isFrench: isFrench,
                    );

                    if (wide) {
                      return SizedBox(
                        height: 560,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 340, child: left),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(child: right),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        left,
                        const SizedBox(height: AppSpacing.lg),
                        right,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftPane extends StatelessWidget {
  const _LeftPane({
    required this.isLoadingCourses,
    required this.isLoadingLessons,
    required this.courses,
    required this.selectedCourse,
    required this.selectedLevel,
    required this.lessons,
    required this.selectedLesson,
    required this.completedLessonIds,
    required this.isFrench,
    required this.onLevelChanged,
    required this.onCourseChanged,
    required this.onLessonSelected,
  });

  final bool isLoadingCourses;
  final bool isLoadingLessons;
  final List<Course> courses;
  final Course? selectedCourse;
  final String selectedLevel;
  final List<Lesson> lessons;
  final Lesson? selectedLesson;
  final Set<String> completedLessonIds;
  final bool isFrench;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<Course> onCourseChanged;
  final ValueChanged<Lesson> onLessonSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedLevel,
                decoration: const InputDecoration(isDense: true),
                items: _kLevels
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onLevelChanged(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (courses.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: selectedCourse?.id,
            isExpanded: true,
            decoration: const InputDecoration(isDense: true),
            items: courses
                .map(
                  (course) => DropdownMenuItem(
                    value: course.id,
                    child: Text(
                      localizedText(course.title, course.frenchTitle, isFrench),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              final course = courses.firstWhere((c) => c.id == id);
              onCourseChanged(course);
            },
          ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: isLoadingCourses || isLoadingLessons
              ? const ShimmerListLoader(itemCount: 3, itemHeight: 84)
              : lessons.isEmpty
                  ? EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: l10n.lessonsHubTitle,
                      message: l10n.lessonsHubEmptyMessage,
                    )
                  : ListView.separated(
                      itemCount: lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        final selected = lesson.id == selectedLesson?.id;
                        final completed = completedLessonIds.contains(lesson.id);
                        return InkWell(
                          borderRadius: AppRadius.medium,
                          onTap: () => onLessonSelected(lesson),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                              borderRadius: AppRadius.medium,
                              border: Border.all(
                                color: selected ? AppColors.primary : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${lesson.orderNumber}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    localizedText(lesson.title, lesson.frenchTitle, isFrench),
                                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (completed)
                                  const Icon(Icons.check_circle, color: AppColors.success, size: 18)
                                else if (lesson.estimatedMinutes != null)
                                  Text(
                                    l10n.lessonsHubMinutesShort(lesson.estimatedMinutes!),
                                    style: AppTypography.caption,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _DetailPane extends StatelessWidget {
  const _DetailPane({required this.lesson, required this.course, required this.isFrench});

  final Lesson? lesson;
  final Course? course;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = lesson;

    if (current == null || course == null) {
      return Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.large),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(l10n.lessonsHubSelectLessonMessage, style: AppTypography.caption),
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.large),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (current.coverImageUrl != null && current.coverImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: AppRadius.medium,
                child: Image.network(
                  AppConfig.resolveUrl(current.coverImageUrl!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (current.coverImageUrl != null && current.coverImageUrl!.isNotEmpty)
              const SizedBox(height: AppSpacing.lg),
            Text(
              'Leçon ${current.orderNumber}',
              style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
            Text(
              localizedText(current.title, current.frenchTitle, isFrench),
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                Text(course!.level.replaceAll('_', ' '), style: AppTypography.caption),
                if (current.estimatedMinutes != null)
                  Text('· ${l10n.lessonsHubMinutesShort(current.estimatedMinutes!)}', style: AppTypography.caption),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              localizedText(current.summary, current.frenchSummary, isFrench),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.lessonsHubStartLessonButton,
              onPressed: () => context.push('/courses/${course!.id}/lessons/${current.id}'),
            ),
            if (current.learningObjectives.isNotEmpty || current.outcomes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (current.learningObjectives.isNotEmpty)
                    Expanded(
                      child: _BulletColumn(
                        title: l10n.lessonsHubLearningObjectivesTitle,
                        items: current.learningObjectives,
                      ),
                    ),
                  if (current.learningObjectives.isNotEmpty && current.outcomes.isNotEmpty)
                    const SizedBox(width: AppSpacing.lg),
                  if (current.outcomes.isNotEmpty)
                    Expanded(
                      child: _BulletColumn(
                        title: l10n.lessonsHubWhatYouWillLearnTitle,
                        items: current.outcomes,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletColumn extends StatelessWidget {
  const _BulletColumn({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title.copyWith(fontSize: 14)),
        const SizedBox(height: AppSpacing.sm),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 6, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(item, style: AppTypography.body)),
              ],
            ),
          ),
      ],
    );
  }
}
