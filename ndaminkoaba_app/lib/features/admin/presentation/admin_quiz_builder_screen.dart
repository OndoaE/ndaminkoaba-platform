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
import '../../../l10n/app_localizations.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';
import '../domain/quiz_paste_parser.dart';

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
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final frenchTitleController = TextEditingController();
  final frenchDescriptionController = TextEditingController();
  final passingScoreController = TextEditingController(text: '70');

  bool isLoading = true;
  bool isCreatingQuiz = false;
  bool _defaultTitleSet = false;
  AdminQuiz? quiz;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultTitleSet) {
      _defaultTitleSet = true;
      titleController.text = AppLocalizations.of(context).adminQuizBuilderDefaultTitle;
    }
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
    final l10n = AppLocalizations.of(context);
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
      _showMessage(extractErrorMessage(e, fallback: l10n.adminQuizBuilderCreateError));
    } finally {
      if (mounted) setState(() => isCreatingQuiz = false);
    }
  }

  Future<void> editQuizInfo(AdminQuiz currentQuiz) async {
    final l10n = AppLocalizations.of(context);
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
        title: Text(l10n.adminQuizBuilderEditQuizTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: l10n.adminQuizBuilderTitleLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: l10n.adminQuizBuilderDescriptionLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchTitleCtrl,
                decoration: InputDecoration(labelText: l10n.adminQuizBuilderFrenchTitleLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchDescCtrl,
                decoration: InputDecoration(labelText: l10n.adminQuizBuilderFrenchDescriptionLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: scoreCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.adminQuizBuilderPassingScoreLabel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.adminQuizBuilderCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.adminQuizBuilderSave),
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
      _showMessage(l10n.adminQuizBuilderQuizUpdated);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminQuizBuilderUpdateQuizError));
    }
  }

  Future<void> deleteQuizEntirely(AdminQuiz currentQuiz) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminQuizBuilderDeleteQuizTitle),
        content: Text(
          l10n.adminQuizBuilderDeleteQuizConfirm(
            currentQuiz.title,
            currentQuiz.questions.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.adminQuizBuilderCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.adminQuizBuilderDelete),
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
      _showMessage(extractErrorMessage(e, fallback: l10n.adminQuizBuilderDeleteQuizError));
    }
  }

  Future<void> addQuestion() async {
    final l10n = AppLocalizations.of(context);
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
      _showMessage(l10n.adminQuizBuilderQuestionAdded);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminQuizBuilderAddQuestionError));
    }
  }

  Future<void> pasteQuiz() async {
    final l10n = AppLocalizations.of(context);
    final currentQuiz = quiz;
    if (currentQuiz == null) return;

    final parsedQuestions = await showDialog<List<ParsedQuestion>>(
      context: context,
      builder: (context) => const _PasteQuizDialog(),
    );
    if (parsedQuestions == null || parsedQuestions.isEmpty) return;

    var succeeded = 0;
    var failed = 0;
    String? firstError;
    for (final q in parsedQuestions) {
      try {
        await repository.createQuestionWithChoices(
          quizId: currentQuiz.id,
          questionText: q.questionText,
          explanation: q.explanation,
          frenchQuestionText: q.frenchQuestionText,
          frenchExplanation: q.frenchExplanation,
          choices: [
            for (final c in q.choices)
              (text: c.text, frenchText: c.frenchText, isCorrect: c.isCorrect),
          ],
        );
        succeeded++;
      } on DioException catch (e) {
        failed++;
        firstError ??= extractErrorMessage(e, fallback: l10n.adminQuizBuilderUnknownServerError);
      } catch (e) {
        failed++;
        firstError ??= e.toString();
      }
    }

    await load();
    _showMessage(
      failed == 0
          ? l10n.adminQuizBuilderImportSuccess(succeeded)
          : l10n.adminQuizBuilderImportPartial(
              succeeded,
              failed,
              firstError != null ? ' — $firstError' : '',
            ),
    );
  }

  Future<void> editQuestion(AdminQuestion question) async {
    final l10n = AppLocalizations.of(context);
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
      _showMessage(l10n.adminQuizBuilderQuestionUpdated);
    } on DioException catch (e) {
      _showMessage(
        extractErrorMessage(e, fallback: l10n.adminQuizBuilderUpdateQuestionError),
      );
    }
  }

  Future<void> deleteQuestion(AdminQuestion question) async {
    final l10n = AppLocalizations.of(context);
    try {
      await repository.deleteQuestion(
        question.id,
        question.choices.map((c) => c.id).toList(),
      );
      await load();
    } on DioException catch (e) {
      _showMessage(
        extractErrorMessage(e, fallback: l10n.adminQuizBuilderDeleteQuestionError),
      );
    }
  }

  Future<void> markCorrect(AdminQuestion question, AdminChoice choice) async {
    final l10n = AppLocalizations.of(context);
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
        extractErrorMessage(e, fallback: l10n.adminQuizBuilderUpdateAnswerKeyError),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: l10n.adminQuizBuilderAppBarTitle(
          widget.lessonTitle ?? l10n.adminQuizBuilderDefaultLessonTitle,
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 3, itemHeight: 96),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: quiz == null
                    ? _buildCreateForm(l10n)
                    : _buildQuizEditor(quiz!, l10n),
              ),
      ),
    );
  }

  Widget _buildCreateForm(AppLocalizations l10n) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminQuizBuilderNoQuizYetTitle, style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.adminQuizBuilderNoQuizYetDescription,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(label: l10n.adminQuizBuilderQuizTitleLabel, controller: titleController),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: l10n.adminQuizBuilderDescriptionLabel,
            controller: descriptionController,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: l10n.adminQuizBuilderFrenchTitleLabel,
            controller: frenchTitleController,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: l10n.adminQuizBuilderFrenchDescriptionLabel,
            controller: frenchDescriptionController,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumTextField(
            label: l10n.adminQuizBuilderPassingScoreLabel,
            controller: passingScoreController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.adminQuizBuilderCreateQuizButton,
            isLoading: isCreatingQuiz,
            onPressed: createQuiz,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizEditor(AdminQuiz quiz, AppLocalizations l10n) {
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
                      l10n.adminQuizBuilderPassMarkSummary(quiz.passingScore, quiz.questions.length),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: l10n.adminQuizBuilderEditQuizInfoTooltip,
                onPressed: () => editQuizInfo(quiz),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                tooltip: l10n.adminQuizBuilderDeleteQuizTooltip,
                onPressed: () => deleteQuizEntirely(quiz),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.adminQuizBuilderQuestionsHeading, style: AppTypography.title),
            Row(
              children: [
                TextButton.icon(
                  onPressed: pasteQuiz,
                  icon: const Icon(Icons.content_paste),
                  label: Text(l10n.adminQuizBuilderPasteQuizButton),
                ),
                TextButton.icon(
                  onPressed: addQuestion,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.adminQuizBuilderAddQuestionButton),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (quiz.questions.isEmpty)
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminQuizBuilderNoQuestionsYet,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.adminQuizBuilderPasteQuizHint,
                  style: AppTypography.caption,
                ),
              ],
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
                          tooltip: l10n.adminQuizBuilderEditQuestionTooltip,
                          onPressed: () => editQuestion(entry.value),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                          ),
                          tooltip: l10n.adminQuizBuilderDeleteQuestionTooltip,
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
                          l10n.adminQuizBuilderNoCorrectAnswerSet,
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
    final l10n = AppLocalizations.of(context);
    if (questionController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adminQuizBuilderQuestionTooShortError),
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
        SnackBar(content: Text(l10n.adminQuizBuilderTooFewChoicesError)),
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
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.initial != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.adminQuizBuilderEditQuestionDialogTitle : l10n.adminQuizBuilderAddQuestionButton),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(labelText: l10n.adminQuizBuilderQuestionLabel),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: explanationController,
              decoration: InputDecoration(
                labelText: l10n.adminQuizBuilderExplanationLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: frenchQuestionController,
              decoration: InputDecoration(
                labelText: l10n.adminQuizBuilderFrenchQuestionLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: frenchExplanationController,
              decoration: InputDecoration(
                labelText: l10n.adminQuizBuilderFrenchExplanationLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.adminQuizBuilderChoicesHelper,
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
                              hintText: l10n.adminQuizBuilderChoiceHint(i + 1),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: frenchChoiceControllers[i],
                            decoration: InputDecoration(
                              hintText: l10n.adminQuizBuilderFrenchOptionalHint,
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
                label: Text(l10n.adminQuizBuilderAddAnotherChoiceButton),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.adminQuizBuilderCancel),
        ),
        FilledButton(
          onPressed: submit,
          child: Text(isEditing ? l10n.adminQuizBuilderSave : l10n.adminQuizBuilderAddQuestionButton),
        ),
      ],
    );
  }
}

/// Lets an admin paste a whole quiz (written elsewhere) as plain text,
/// previews how it was parsed into questions/choices, and hands back the
/// list to import — the same shape [ContentRepository.createQuestionWithChoices]
/// already consumes for a manually-created question.
class _PasteQuizDialog extends StatefulWidget {
  const _PasteQuizDialog();

  @override
  State<_PasteQuizDialog> createState() => _PasteQuizDialogState();
}

class _PasteQuizDialogState extends State<_PasteQuizDialog> {
  final textController = TextEditingController();
  QuizPasteParseResult? result;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void parse() {
    setState(() => result = parseQuizPaste(textController.text));
  }

  void backToPaste() {
    setState(() => result = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = result;
    return AlertDialog(
      title: Text(current == null ? l10n.adminQuizBuilderPasteQuizButton : l10n.adminQuizBuilderPreviewImportTitle),
      content: SizedBox(
        width: 520,
        child: current == null ? _buildPasteStep(l10n) : _buildPreviewStep(current, l10n),
      ),
      actions: current == null
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.adminQuizBuilderCancel),
              ),
              FilledButton(
                onPressed: textController.text.trim().isEmpty ? null : parse,
                child: Text(l10n.adminQuizBuilderParseButton),
              ),
            ]
          : [
              TextButton(onPressed: backToPaste, child: Text(l10n.adminQuizBuilderBackButton)),
              FilledButton(
                onPressed: current.questions.where((q) => q.isValid).isEmpty
                    ? null
                    : () => Navigator.pop(
                        context,
                        current.questions.where((q) => q.isValid).toList(),
                      ),
                child: Text(
                  l10n.adminQuizBuilderImportButton(current.questions.where((q) => q.isValid).length),
                ),
              ),
            ],
    );
  }

  Widget _buildPasteStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminQuizBuilderPasteInstructions,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.adminQuizBuilderPasteExample,
              style: AppTypography.caption.copyWith(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.adminQuizBuilderPasteFormatHelp,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: textController,
            maxLines: 12,
            minLines: 8,
            decoration: InputDecoration(
              hintText: l10n.adminQuizBuilderPasteHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep(QuizPasteParseResult result, AppLocalizations l10n) {
    final validCount = result.questions.where((q) => q.isValid).length;
    return SizedBox(
      height: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminQuizBuilderDetectedCount(result.questions.length, validCount),
            style: AppTypography.caption,
          ),
          if (result.globalWarnings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                result.globalWarnings.join(' '),
                style: AppTypography.caption.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: result.questions.isEmpty
                ? Center(
                    child: Text(
                      l10n.adminQuizBuilderNothingToPreview,
                      style: AppTypography.caption,
                    ),
                  )
                : ListView.separated(
                    itemCount: result.questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final q = result.questions[index];
                      return Opacity(
                        opacity: q.isValid ? 1 : 0.5,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${q.questionText}',
                                style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (q.frenchQuestionText != null)
                                Text(
                                  q.frenchQuestionText!,
                                  style: AppTypography.caption,
                                ),
                              const SizedBox(height: AppSpacing.xs),
                              ...q.choices.map(
                                (c) => Row(
                                  children: [
                                    Icon(
                                      c.isCorrect
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      size: 16,
                                      color: c.isCorrect
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        c.text,
                                        style: AppTypography.caption,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (q.warnings.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    q.warnings.join(' '),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
