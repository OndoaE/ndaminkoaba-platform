import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../progress/data/progress_repository.dart';
import '../data/quiz_repository.dart';
import '../domain/quiz.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.courseId, required this.lessonId});

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final quizRepository = QuizRepository();
  final progressRepository = ProgressRepository();

  bool isLoading = true;
  bool isSubmitting = false;
  Quiz? quiz;
  QuizAttemptResult? result;
  final Map<String, String> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    setState(() => isLoading = true);
    try {
      final fetched = await quizRepository.getQuizForLesson(widget.lessonId);
      if (!mounted) return;
      setState(() {
        quiz = fetched;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> submit() async {
    final l10n = AppLocalizations.of(context);
    final currentQuiz = quiz;
    if (currentQuiz == null) return;

    if (selectedAnswers.length < currentQuiz.questions.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseAnswerAllError)));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final userId = await StorageService.getUserId();
      if (userId == null) return;

      final attemptResult = await quizRepository.submitAttempt(
        userId: userId,
        quizId: currentQuiz.id,
        answers: selectedAnswers,
      );

      if (attemptResult.passed) {
        await progressRepository.markLessonComplete(
          userId: userId,
          lessonId: widget.lessonId,
          score: attemptResult.score,
        );
      }

      if (!mounted) return;
      setState(() {
        result = attemptResult;
        isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.quizSubmitError)));
    }
  }

  void retry() {
    setState(() {
      result = null;
      selectedAnswers.clear();
    });
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
                child: ShimmerListLoader(itemCount: 3, itemHeight: 160),
              );
            }

            final currentQuiz = quiz;
            if (currentQuiz == null) {
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
                      icon: Icons.quiz_outlined,
                      title: l10n.noQuizTitle,
                      message: l10n.noQuizMessage,
                    ),
                  ],
                ),
              );
            }

            if (result != null) {
              return _QuizResultView(
                quiz: currentQuiz,
                result: result!,
                onRetry: retry,
                onDone: () => context.pop(),
                isFrench: isFrench,
              );
            }

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
                    localizedText(
                      currentQuiz.title,
                      currentQuiz.frenchTitle,
                      isFrench,
                    ),
                    style: AppTypography.h1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (localizedText(
                    currentQuiz.description ?? '',
                    currentQuiz.frenchDescription,
                    isFrench,
                  ).isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      localizedText(
                        currentQuiz.description ?? '',
                        currentQuiz.frenchDescription,
                        isFrench,
                      ),
                      style: AppTypography.caption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.passMarkLabel(currentQuiz.passingScore),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ...currentQuiz.questions.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _QuestionCard(
                        index: entry.key + 1,
                        question: entry.value,
                        selectedChoiceId: selectedAnswers[entry.value.id],
                        onSelected: (choiceId) {
                          setState(() {
                            selectedAnswers[entry.value.id] = choiceId;
                          });
                        },
                        isFrench: isFrench,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: l10n.submitQuizButton,
                    isLoading: isSubmitting,
                    onPressed: submit,
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedChoiceId,
    required this.onSelected,
    required this.isFrench,
  });

  final int index;
  final QuizQuestion question;
  final String? selectedChoiceId;
  final ValueChanged<String> onSelected;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.questionLabel(index), style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(
            localizedText(
              question.questionText,
              question.frenchQuestionText,
              isFrench,
            ),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.md),
          ...question.choices.map((choice) {
            final selected = choice.id == selectedChoiceId;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: AppRadius.medium,
                onTap: () => onSelected(choice.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: AppRadius.medium,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          localizedText(
                            choice.choiceText,
                            choice.frenchChoiceText,
                            isFrench,
                          ),
                          style: AppTypography.body.copyWith(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.quiz,
    required this.result,
    required this.onRetry,
    required this.onDone,
    required this.isFrench,
  });

  final Quiz quiz;
  final QuizAttemptResult result;
  final VoidCallback onRetry;
  final VoidCallback onDone;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = result.passed ? AppColors.success : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientHeroCard(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              children: [
                Icon(
                  result.passed ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  result.passed ? l10n.youPassedTitle : l10n.notQuiteThereTitle,
                  style: AppTypography.h2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.scoreSummary(result.score, quiz.passingScore),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.reviewTitle, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          ...quiz.questions.map((question) {
            final questionResult = result.results.firstWhere(
              (r) => r.questionId == question.id,
              orElse: () =>
                  const QuestionResult(questionId: '', isCorrect: false),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PremiumCard(
                child: Row(
                  children: [
                    Icon(
                      questionResult.isCorrect
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: questionResult.isCorrect
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedText(
                              question.questionText,
                              question.frenchQuestionText,
                              isFrench,
                            ),
                          ),
                          if (!questionResult.isCorrect &&
                              localizedText(
                                question.explanation ?? '',
                                question.frenchExplanation,
                                isFrench,
                              ).isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              localizedText(
                                question.explanation ?? '',
                                question.frenchExplanation,
                                isFrench,
                              ),
                              style: AppTypography.caption,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          if (!result.passed)
            PrimaryButton(label: l10n.tryAgainButton, onPressed: onRetry)
          else
            PrimaryButton(label: l10n.continueButton, onPressed: onDone),
        ],
      ),
    );
  }
}
