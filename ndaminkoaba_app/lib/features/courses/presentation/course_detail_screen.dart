import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/network/api_error.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/bouncy_icon_button.dart';
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
import '../../offline/data/offline_course_repository.dart';
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
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  final courseRepository = CourseRepository();
  final progressRepository = ProgressRepository();
  final enrollmentRepository = EnrollmentRepository();
  final certificateRepository = CertificateRepository();
  final offlineCourseRepository = OfflineCourseRepository();

  bool isLoading = true;
  bool hasError = false;
  bool isClaiming = false;
  CourseDetail? course;
  Set<String> completedLessonIds = {};
  bool hasCertificate = false;
  String? userId;

  bool isDownloaded = false;
  bool isDownloading = false;
  int downloadCompleted = 0;
  int downloadTotal = 0;
  bool isOfflineFallback = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      hasError = false;
      isOfflineFallback = false;
    });

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

      final downloaded = kIsWeb
          ? false
          : await offlineCourseRepository.isDownloaded(widget.courseId);

      if (!mounted) return;

      setState(() {
        course = fetchedCourse;
        completedLessonIds = completed;
        hasCertificate = certificates.any((c) => c.courseId == widget.courseId);
        userId = id;
        isDownloaded = downloaded;
        isLoading = false;
      });
    } catch (e) {
      final isConnectivityIssue = !kIsWeb && e is DioException && isConnectivityFailure(e);
      if (isConnectivityIssue && await _loadFromOfflineCache()) return;

      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// Falls back to the downloaded copy (if any) when the live fetch fails
  /// for connectivity reasons. Returns whether a cached copy was found and
  /// rendered — the caller falls through to the normal error state
  /// otherwise. Progress/certificate data isn't cached, so those stay at
  /// their defaults offline.
  Future<bool> _loadFromOfflineCache() async {
    final manifest = await offlineCourseRepository.loadManifest(widget.courseId);
    if (manifest == null) return false;

    if (!mounted) return true;
    setState(() {
      course = CourseDetail.fromManifest(manifest);
      isDownloaded = true;
      isOfflineFallback = true;
      isLoading = false;
    });
    return true;
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

      await _showCertificateEarnedCelebration();
      if (!mounted) return;
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

  Future<void> downloadForOffline() async {
    setState(() {
      isDownloading = true;
      downloadCompleted = 0;
      downloadTotal = 0;
    });

    try {
      await offlineCourseRepository.downloadCourse(
        widget.courseId,
        onProgress: (completed, total) {
          if (!mounted) return;
          setState(() {
            downloadCompleted = completed;
            downloadTotal = total;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        isDownloaded = true;
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).downloadCompleteMessage),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).downloadFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> removeOfflineDownload() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeDownloadConfirmTitle),
        content: Text(l10n.removeDownloadConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.removeDownloadButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await offlineCourseRepository.removeDownload(widget.courseId);
    if (!mounted) return;
    setState(() => isDownloaded = false);
  }

  Future<void> _showCertificateEarnedCelebration() {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: PremiumCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Lottie.asset(
                  'assets/lottie/quiz_success.json',
                  fit: BoxFit.contain,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.workspace_premium,
                    color: AppColors.secondary,
                    size: 96,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.certificateEarnedTitle,
                style: AppTypography.h2.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.certificateEarnedMessage,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: l10n.certificateEarnedButton,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

            if (hasError) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BouncyIconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    EmptyState(
                      icon: Icons.wifi_off_outlined,
                      iconColor: AppColors.error,
                      title: l10n.commonSomethingWrong,
                      action: PrimaryButton(
                        label: l10n.commonRetry,
                        onPressed: load,
                      ),
                    ),
                  ],
                ),
              );
            }

            final currentCourse = course;
            if (currentCourse == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BouncyIconButton(
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
                  BouncyIconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  if (isOfflineFallback) ...[
                    const SizedBox(height: AppSpacing.md),
                    _OfflineBanner(label: l10n.downloadedOfflineLabel),
                  ],
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

                  if (!kIsWeb) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _OfflineDownloadCard(
                      isDownloaded: isDownloaded,
                      isDownloading: isDownloading,
                      downloadCompleted: downloadCompleted,
                      downloadTotal: downloadTotal,
                      onDownload: downloadForOffline,
                      onRemove: removeOfflineDownload,
                    ),
                  ],

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

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineDownloadCard extends StatelessWidget {
  const _OfflineDownloadCard({
    required this.isDownloaded,
    required this.isDownloading,
    required this.downloadCompleted,
    required this.downloadTotal,
    required this.onDownload,
    required this.onRemove,
  });

  final bool isDownloaded;
  final bool isDownloading;
  final int downloadCompleted;
  final int downloadTotal;
  final VoidCallback onDownload;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isDownloading) {
      final percent = downloadTotal == 0
          ? 0
          : ((downloadCompleted / downloadTotal) * 100).round();
      return PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.downloadingOfflineLabel(percent),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: downloadTotal == 0 ? null : percent / 100,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isDownloaded) {
      return PremiumCard(
        child: Row(
          children: [
            const Icon(Icons.offline_pin, color: AppColors.success),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                l10n.downloadedOfflineLabel,
                style: AppTypography.title,
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: Text(l10n.removeDownloadButton),
            ),
          ],
        ),
      );
    }

    return PrimaryButton(
      label: l10n.downloadForOfflineButton,
      icon: Icons.download_outlined,
      onPressed: onDownload,
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
