import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';

class AdminQuizBuilderScreen extends StatefulWidget {
  const AdminQuizBuilderScreen({
    super.key,
    required this.lessonId,
    this.lessonTitle,
  });

  final String lessonId;
  final String? lessonTitle;

  @override
  State<AdminQuizBuilderScreen> createState() => _AdminQuizBuilderScreenState();
}

class _AdminQuizBuilderScreenState extends State<AdminQuizBuilderScreen> {
  final repository = ContentRepository();
  final titleController = TextEditingController(text: 'Lesson Quiz');
  final descriptionController = TextEditingController();
  final frenchTitleController = TextEditingController();
  final frenchDescriptionController = TextEditingController();
  final passingScoreController = TextEditingController(text: '70');

  bool isLoading = true;
  bool isCreatingQuiz = false;
  AdminQuiz? quiz;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    frenchTitleController.dispose();
    frenchDescriptionController.dispose();
    passingScoreController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final fetched = await repository.getQuizForLesson(widget.lessonId);
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> createQuiz() async {
    setState(() => isCreatingQuiz = true);
    try {
      await repository.createQuiz(
        lessonId: widget.lessonId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        frenchTitle: frenchTitleController.text.trim(),
        frenchDescription: frenchDescriptionController.text.trim(),
        passingScore: int.tryParse(passingScoreController.text.trim()) ?? 70,
      );
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not create quiz.'));
    } finally {
      if (mounted) setState(() => isCreatingQuiz = false);
    }
  }

  Future<void> editQuizInfo(AdminQuiz currentQuiz) async {
    final titleCtrl = TextEditingController(text: currentQuiz.title);
    final descCtrl = TextEditingController(text: currentQuiz.description ?? '');
    final frenchTitleCtrl = TextEditingController(text: currentQuiz.frenchTitle ?? '');
    final frenchDescCtrl = TextEditingController(text: currentQuiz.frenchDescription ?? '');
    final scoreCtrl = TextEditingController(
      text: '${currentQuiz.passingScore}',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quiz'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchTitleCtrl,
                decoration: const InputDecoration(labelText: 'French Title (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchDescCtrl,
                decoration: const InputDecoration(labelText: 'French Description (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: scoreCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Passing Score (%)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await repository.updateQuiz(
        currentQuiz.id,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        frenchTitle: frenchTitleCtrl.text.trim(),
        frenchDescription: frenchDescCtrl.text.trim(),
        passingScore: int.tryParse(scoreCtrl.text.trim()),
      );
      await load();
      _showMessage('Quiz updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update quiz.'));
    }
  }

  Future<void> deleteQuizEntirely(AdminQuiz currentQuiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Delete "${currentQuiz.title}" and all ${currentQuiz.questions.length} question(s)? '
          'Learners will no longer be able to complete this lesson via quiz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repository.deleteQuiz(currentQuiz);
      if (!mounted) return;
      Navigator.pop(context);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete quiz.'));
    }
  }

  Future<void> addQuestion() async {
    final currentQuiz = quiz;
    if (currentQuiz == null) return;

    final result = await showDialog<_QuestionFormResult>(
      context: context,
      builder: (context) => const _QuestionFormDialog(),
    );
    if (result == null) return;

    try {
      await repository.createQuestionWithChoices(
        quizId: currentQuiz.id,
        questionText: result.questionText,
        explanation: result.explanation,
        frenchQuestionText: result.frenchQuestionText,
        frenchExplanation: result.frenchExplanation,
        choices: result.choices,
      );
      await load();
      _showMessage('Question added.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add question.'));
    }
  }

  Future<void> editQuestion(AdminQuestion question) async {
    final result = await showDialog<_QuestionFormResult>(
      context: context,
      builder: (context) => _QuestionFormDialog(initial: question),
    );
    if (result == null) return;

    try {
      await repository.updateQuestionWithChoices(
        questionId: question.id,
        oldChoiceIds: question.choices.map((c) => c.id).toList(),
        questionText: result.questionText,
        explanation: result.explanation,
        frenchQuestionText: result.frenchQuestionText,
        frenchExplanation: result.frenchExplanation,
        choices: result.choices,
      );
      await load();
      _showMessage('Question updated.');
    } on DioException catch (e) {
      _showMessage(
        extractErrorMessage(e, fallback: 'Could not update question.'),
      );
    }
  }

  Future<void> deleteQuestion(AdminQuestion question) async {
    try {
      await repository.deleteQuestion(
        question.id,
        question.choices.map((c) => c.id).toList(),
      );
      await load();
    } on DioException catch (e) {
      _showMessage(
        extractErrorMessage(e, fallback: 'Could not delete question.'),
      );
    }
  }

  Future<void> markCorrect(AdminQuestion question, AdminChoice choice) async {
    try {
      await repository.setChoiceCorrect(choice.id, true);
      for (final other in question.choices) {
        if (other.id != choice.id && other.isCorrect) {
          await repository.setChoiceCorrect(other.id, false);
        }
      }
      await load();
    } on DioException catch (e) {
      _showMessage(
        extractErrorMessage(e, fallback: 'Could not update answer key.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: 'Quiz — ${widget.lessonTitle ?? 'Lesson'}'),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 3, itemHeight: 96),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: quiz == null
                    ? _buildCreateForm()
                    : _buildQuizEditor(quiz!),
              ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This lesson has no quiz yet', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create one so learners can complete this lesson by passing it.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(label: 'Quiz Title', controller: titleController),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: 'Description',
            controller: descriptionController,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: 'French Title (optional)',
            controller: frenchTitleController,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: 'French Description (optional)',
            controller: frenchDescriptionController,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: 'Passing Score (%)',
            controller: passingScoreController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Create Quiz',
            isLoading: isCreatingQuiz,
            onPressed: createQuiz,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizEditor(AdminQuiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientHeroCard(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: AppTypography.title.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Pass mark: ${quiz.passingScore}% • ${quiz.questions.length} questions',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edit quiz info',
                onPressed: () => editQuizInfo(quiz),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: 'Delete quiz',
                onPressed: () => deleteQuizEntirely(quiz),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Questions', style: AppTypography.title),
            TextButton.icon(
              onPressed: addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (quiz.questions.isEmpty)
          PremiumCard(
            child: Text(
              'No questions yet. A quiz needs at least one question before a learner can take it.',
              style: AppTypography.caption,
            ),
          )
        else
          ...quiz.questions.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.secondary.withValues(
                            alpha: 0.25,
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            entry.value.questionText,
                            style: AppTypography.title,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit question',
                          onPressed: () => editQuestion(entry.value),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          tooltip: 'Delete question',
                          onPressed: () => deleteQuestion(entry.value),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...entry.value.choices.map(
                      (choice) => InkWell(
                        onTap: () => markCorrect(entry.value, choice),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                choice.isCorrect
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: choice.isCorrect
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  choice.choiceText,
                                  style: choice.isCorrect
                                      ? const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (entry.value.choices.every((c) => !c.isCorrect))
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          'No correct answer set — tap a choice above to mark it.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestionFormResult {
  const _QuestionFormResult({
    required this.questionText,
    this.explanation,
    this.frenchQuestionText,
    this.frenchExplanation,
    required this.choices,
  });

  final String questionText;
  final String? explanation;
  final String? frenchQuestionText;
  final String? frenchExplanation;
  final List<({String text, String? frenchText, bool isCorrect})> choices;
}

class _QuestionFormDialog extends StatefulWidget {
  const _QuestionFormDialog({this.initial});

  /// When set, the dialog opens pre-filled for editing instead of adding.
  final AdminQuestion? initial;

  @override
  State<_QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<_QuestionFormDialog> {
  late final questionController = TextEditingController(
    text: widget.initial?.questionText ?? '',
  );
  late final explanationController = TextEditingController(
    text: widget.initial?.explanation ?? '',
  );
  late final frenchQuestionController = TextEditingController(
    text: widget.initial?.frenchQuestionText ?? '',
  );
  late final frenchExplanationController = TextEditingController(
    text: widget.initial?.frenchExplanation ?? '',
  );
  late final List<TextEditingController> choiceControllers =
      widget.initial != null
      ? widget.initial!.choices
            .map((c) => TextEditingController(text: c.choiceText))
            .toList()
      : List.generate(4, (_) => TextEditingController());
  late final List<TextEditingController> frenchChoiceControllers =
      widget.initial != null
      ? widget.initial!.choices
            .map((c) => TextEditingController(text: c.frenchChoiceText ?? ''))
            .toList()
      : List.generate(4, (_) => TextEditingController());
  late int correctIndex = widget.initial != null
      ? widget.initial!.choices
            .indexWhere((c) => c.isCorrect)
            .clamp(0, choiceControllers.length - 1)
      : 0;

  @override
  void dispose() {
    questionController.dispose();
    explanationController.dispose();
    frenchQuestionController.dispose();
    frenchExplanationController.dispose();
    for (final c in choiceControllers) {
      c.dispose();
    }
    for (final c in frenchChoiceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void addChoiceField() {
    if (choiceControllers.length >= 6) return;
    setState(() {
      choiceControllers.add(TextEditingController());
      frenchChoiceControllers.add(TextEditingController());
    });
  }

  void removeChoiceField(int index) {
    if (choiceControllers.length <= 2) return;
    setState(() {
      choiceControllers.removeAt(index).dispose();
      frenchChoiceControllers.removeAt(index).dispose();
      if (correctIndex >= choiceControllers.length) {
        correctIndex = choiceControllers.length - 1;
      } else if (correctIndex == index) {
        correctIndex = 0;
      }
    });
  }

  void submit() {
    if (questionController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question text must be at least 5 characters.'),
        ),
      );
      return;
    }

    final filled = <int>[];
    for (var i = 0; i < choiceControllers.length; i++) {
      if (choiceControllers[i].text.trim().isNotEmpty) filled.add(i);
    }
    if (filled.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 2 answer choices.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _QuestionFormResult(
        questionText: questionController.text.trim(),
        explanation: explanationController.text.trim().isEmpty
            ? null
            : explanationController.text.trim(),
        frenchQuestionText: frenchQuestionController.text.trim().isEmpty
            ? null
            : frenchQuestionController.text.trim(),
        frenchExplanation: frenchExplanationController.text.trim().isEmpty
            ? null
            : frenchExplanationController.text.trim(),
        choices: [
          for (final i in filled)
            (
              text: choiceControllers[i].text.trim(),
              frenchText: frenchChoiceControllers[i].text.trim().isEmpty
                  ? null
                  : frenchChoiceControllers[i].text.trim(),
              isCorrect: i == correctIndex,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Question' : 'Add Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: explanationController,
              decoration: const InputDecoration(
                labelText: 'Explanation (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: frenchQuestionController,
              decoration: const InputDecoration(
                labelText: 'French Question (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: frenchExplanationController,
              decoration: const InputDecoration(
                labelText: 'French Explanation (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Choices — select the correct one',
              style: AppTypography.caption,
            ),
            RadioGroup<int>(
              groupValue: correctIndex,
              onChanged: (value) => setState(() => correctIndex = value ?? 0),
              child: Column(
                children: List.generate(
                  choiceControllers.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        Radio<int>(value: i),
                        Expanded(
                          child: TextField(
                            controller: choiceControllers[i],
                            decoration: InputDecoration(
                              hintText: 'Choice ${i + 1}',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: frenchChoiceControllers[i],
                            decoration: InputDecoration(
                              hintText: 'French (optional)',
                            ),
                          ),
                        ),
                        if (choiceControllers.length > 2)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => removeChoiceField(i),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (choiceControllers.length < 6)
              TextButton.icon(
                onPressed: addChoiceField,
                icon: const Icon(Icons.add),
                label: const Text('Add another choice'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: submit,
          child: Text(isEditing ? 'Save' : 'Add Question'),
        ),
      ],
    );
  }
}
