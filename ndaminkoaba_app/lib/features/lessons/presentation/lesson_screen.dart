import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/locale/localized_text.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../progress/data/progress_repository.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/domain/quiz.dart';
import '../data/lesson_progress_service.dart';
import '../data/lesson_repository.dart';
import '../domain/lesson.dart';
import '../domain/models/lesson_image.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final repository = LessonRepository();
  final progressService = LessonProgressService();
  final progressRepository = ProgressRepository();
  final quizRepository = QuizRepository();

  bool isLoading = true;
  bool hasError = false;
  Lesson? lesson;
  List<Lesson> siblingLessons = [];
  Quiz? quiz;
  List<LessonImage> lessonImages = [];

  @override
  void initState() {
    super.initState();
    loadLesson();
  }

  Future<void> loadLesson() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final fetchedLesson = await repository.getLessonById(widget.lessonId);

      List<Lesson> siblings = [fetchedLesson];
      try {
        siblings = await repository.getLessonsByModule(fetchedLesson.moduleId);
        siblings.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
      } catch (_) {
        // If sibling lookup fails, fall back to just this lesson so the
        // screen can still render (no "next lesson" navigation in that case).
        siblings = [fetchedLesson];
      }

      Quiz? fetchedQuiz;
      try {
        fetchedQuiz = await quizRepository.getQuizForLesson(widget.lessonId);
      } catch (_) {
        fetchedQuiz = null;
      }

      List<LessonImage> fetchedImages = [];
      try {
        fetchedImages = await repository.getLessonImages(widget.lessonId);
      } catch (_) {
        fetchedImages = [];
      }

      if (!mounted) return;

      setState(() {
        lesson = fetchedLesson;
        siblingLessons = siblings;
        quiz = fetchedQuiz;
        lessonImages = fetchedImages;
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
                child: ShimmerListLoader(itemCount: 2, itemHeight: 140),
              );
            }

            if (hasError || lesson == null) {
              return _LessonNotFound(onRetry: loadLesson);
            }

            final currentLesson = lesson!;
            final currentIndex = siblingLessons.indexWhere(
              (item) => item.id == currentLesson.id,
            );
            final hasNextLesson =
                currentIndex != -1 && currentIndex < siblingLessons.length - 1;
            final lessonContent = localizedText(
              currentLesson.content,
              currentLesson.frenchContent,
              isFrench,
            );
            final lessonSummary = localizedText(
              currentLesson.summary,
              currentLesson.frenchSummary,
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
                  Text(
                    l10n.lessonNumberLabel(currentLesson.orderNumber),
                    style: AppTypography.caption,
                  ),
                  Text(
                    localizedText(
                      currentLesson.title,
                      currentLesson.frenchTitle,
                      isFrench,
                    ),
                    style: AppTypography.h1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentLesson.audioUrl.isNotEmpty) ...[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.volume_up,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        Text(
                          lessonContent.isNotEmpty
                              ? lessonContent
                              : l10n.lessonNoContent,
                          style: AppTypography.h2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (lessonImages.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.illustratedWordsTitle, style: AppTypography.title),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: lessonImages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final image = lessonImages[index];
                                return SizedBox(
                                  width: 110,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: AppRadius.medium,
                                          child: Image.network(
                                            AppConfig.resolveUrl(image.imageUrl),
                                            width: 110,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: AppColors.surface,
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.broken_image_outlined),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        image.word,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.summaryTitle, style: AppTypography.title),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          lessonSummary.isNotEmpty
                              ? lessonSummary
                              : l10n.noSummary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (quiz != null)
                    PrimaryButton(
                      label: l10n.takeQuizButton,
                      icon: Icons.quiz,
                      onPressed: () {
                        context.push(
                          '/courses/${widget.courseId}/lessons/${currentLesson.id}/quiz',
                        );
                      },
                    )
                  else
                    PrimaryButton(
                      label: hasNextLesson
                          ? l10n.nextLessonButton
                          : l10n.finishLessonButton,
                      icon: hasNextLesson
                          ? Icons.arrow_forward
                          : Icons.check_circle,
                      onPressed: () async {
                        final userId = await StorageService.getUserId();

                        await progressService.markCompleted(
                          courseId: widget.courseId,
                          lessonId: currentLesson.id,
                        );

                        if (userId != null) {
                          try {
                            await progressRepository.markLessonComplete(
                              userId: userId,
                              lessonId: currentLesson.id,
                            );
                          } catch (_) {
                            // Local cache above still lets the learner keep
                            // moving even if the server call fails.
                          }
                        }

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.lessonCompletedMessage)),
                        );

                        if (hasNextLesson) {
                          final nextLesson = siblingLessons[currentIndex + 1];

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonScreen(
                                courseId: widget.courseId,
                                lessonId: nextLesson.id,
                              ),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
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

class _LessonNotFound extends StatelessWidget {
  const _LessonNotFound({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            icon: Icons.error_outline,
            iconColor: AppColors.error,
            title: l10n.lessonNotFoundTitle,
            message: l10n.lessonNotFoundMessage,
            action: PrimaryButton(label: l10n.commonRetry, onPressed: onRetry),
          ),
        ],
      ),
    );
  }
}
