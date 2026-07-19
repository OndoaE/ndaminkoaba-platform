import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../certificates/data/certificate_repository.dart';
import '../../progress/data/progress_repository.dart';
import '../data/course_repository.dart';
import '../data/enrollment_repository.dart';
import '../domain/models/course_detail.dart';

String _levelLabel(AppLocalizations l10n, String level) {
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

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  final courseRepository = CourseRepository();
  final progressRepository = ProgressRepository();
  final enrollmentRepository = EnrollmentRepository();
  final certificateRepository = CertificateRepository();

  bool isLoading = true;
  bool isClaiming = false;
  CourseDetail? course;
  Set<String> completedLessonIds = {};
  bool hasCertificate = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);

    try {
      final id = await StorageService.getUserId();
      final results = await Future.wait([
        courseRepository.getCourseDetail(widget.courseId),
        if (id != null) progressRepository.getCompletedLessonIds(id),
        certificateRepository.getMyCertificates(),
      ]);

      if (id != null) {
        // Fire-and-forget: keeps the Enrollment table (and dashboard/admin
        // aggregates) accurate without blocking the screen on it.
        enrollmentRepository
            .ensureEnrolled(userId: id, courseId: widget.courseId)
            .catchError((_) {});
      }

      if (!mounted) return;

      final fetchedCourse = results[0] as CourseDetail;
      final completed = id != null ? results[1] as Set<String> : <String>{};
      final certificates = results[id != null ? 2 : 1] as List;

      setState(() {
        course = fetchedCourse;
        completedLessonIds = completed;
        hasCertificate = certificates.any((c) => c.courseId == widget.courseId);
        userId = id;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> claimCertificate() async {
    final id = userId;
    if (id == null) return;

    setState(() => isClaiming = true);

    try {
      final certificate = await certificateRepository.claim(
        userId: id,
        courseId: widget.courseId,
      );

      if (!mounted) return;
      setState(() {
        hasCertificate = true;
        isClaiming = false;
      });

      context.push('/certificates/${certificate.id}');
    } catch (_) {
      if (!mounted) return;
      setState(() => isClaiming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).notEligibleCertificateError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 3, itemHeight: 130),
              );
            }

            final currentCourse = course;
            if (currentCourse == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: l10n.courseNotFoundTitle,
                      message: l10n.courseNotFoundMessage,
                    ),
                  ],
                ),
              );
            }

            final sortedModules = [...currentCourse.modules]
              ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
            final orderedLessons = sortedModules.expand((module) {
              final lessons = [...module.lessons]
                ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
              return lessons;
            }).toList();

            // A lesson is locked until the one immediately before it in
            // course order is finished — a single continuous chain across
            // module boundaries, independent of the per-module "Lesson N"
            // display numbering.
            final lockedLessonIds = <String>{};
            for (var i = 1; i < orderedLessons.length; i++) {
              if (!completedLessonIds.contains(orderedLessons[i - 1].id)) {
                lockedLessonIds.add(orderedLessons[i].id);
              }
            }

            final totalLessons = currentCourse.lessonCount;
            final doneCount = currentCourse.modules
                .expand((m) => m.lessons)
                .where((l) => completedLessonIds.contains(l.id))
                .length;
            final progressValue = totalLessons == 0
                ? 0.0
                : doneCount / totalLessons;
            final isComplete = totalLessons > 0 && doneCount == totalLessons;
            final courseTitle = localizedText(
              currentCourse.title,
              currentCourse.frenchTitle,
              isFrench,
            );
            final courseDescription = localizedText(
              currentCourse.description,
              currentCourse.frenchDescription,
              isFrench,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          courseTitle,
                          style: AppTypography.h1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (currentCourse.level.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _levelLabel(l10n, currentCourse.level),
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(courseDescription, style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.xl),

                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yourProgressLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.progressCompletedSummary(
                            (progressValue * 100).round(),
                            doneCount,
                            totalLessons,
                          ),
                          style: AppTypography.h2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 10,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isComplete) ...[
                    const SizedBox(height: AppSpacing.lg),
                    if (hasCertificate)
                      PrimaryButton(
                        label: l10n.viewCertificateButton,
                        icon: Icons.workspace_premium,
                        onPressed: () => context.push('/certificates'),
                      )
                    else
                      PrimaryButton(
                        label: l10n.claimCertificateButton,
                        icon: Icons.workspace_premium,
                        isLoading: isClaiming,
                        onPressed: claimCertificate,
                      ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  SectionTitle(
                    title: l10n.modulesTitle,
                    subtitle: l10n.modulesSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  ...sortedModules.map(
                    (module) => _ModuleSection(
                      courseId: widget.courseId,
                      module: module,
                      completedLessonIds: completedLessonIds,
                      lockedLessonIds: lockedLessonIds,
                      isFrench: isFrench,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.courseId,
    required this.module,
    required this.completedLessonIds,
    required this.lockedLessonIds,
    required this.isFrench,
  });

  final String courseId;
  final CourseDetailModule module;
  final Set<String> completedLessonIds;
  final Set<String> lockedLessonIds;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final sortedLessons = [...module.lessons]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizedText(module.title, module.frenchTitle, isFrench),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              localizedText(
                module.description,
                module.frenchDescription,
                isFrench,
              ),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.lg),

            ...sortedLessons.map(
              (lesson) => _LessonRow(
                courseId: courseId,
                lesson: lesson,
                completed: completedLessonIds.contains(lesson.id),
                locked: lockedLessonIds.contains(lesson.id),
                isFrench: isFrench,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.courseId,
    required this.lesson,
    required this.completed,
    this.locked = false,
    required this.isFrench,
  });

  final String courseId;
  final CourseDetailLesson lesson;
  final bool completed;
  final bool locked;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final iconColor = locked
        ? AppColors.textSecondary
        : (completed ? AppColors.success : AppColors.primary);

    return InkWell(
      onTap: () {
        if (locked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).lessonLockedMessage),
              backgroundColor: AppColors.primary,
            ),
          );
          return;
        }
        context.push('/courses/$courseId/lessons/${lesson.id}');
      },
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  locked
                      ? Icons.lock_outline
                      : (completed ? Icons.check : Icons.play_arrow),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedText(lesson.title, lesson.frenchTitle, isFrench),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      localizedText(
                        lesson.summary,
                        lesson.frenchSummary,
                        isFrench,
                      ),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
