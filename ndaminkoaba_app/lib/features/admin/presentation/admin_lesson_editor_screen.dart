import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_error.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/lesson_content_preview.dart';
import '../../../design_system/widgets/markdown_formatting_toolbar.dart';
import '../../../design_system/widgets/progress_ring.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../design_system/widgets/status_pill.dart';
import '../data/admin_repository.dart';
import '../data/content_repository.dart';
import '../data/knowledge_repository.dart';
import '../data/lesson_editor_repository.dart';
import '../domain/admin_content_models.dart';
import '../domain/admin_models.dart';
import '../domain/knowledge_models.dart';
import '../domain/lesson_editor_models.dart';

/// Ordered block-type palette — TEXT/DIALOGUE/AUDIO/IMAGE map cleanly onto
/// existing Lesson/LessonImage fields; VOCABULARY/QUIZ/PRONUNCIATION are
/// pointer-only; EXERCISE is last since it's stored but not yet rendered to
/// learners (disclosed in its card).
List<(String, IconData, String)> _blockTypes(AppLocalizations l10n) => [
      ('TEXT', Icons.article_outlined, l10n.adminBlockTypeText),
      ('DIALOGUE', Icons.forum_outlined, l10n.adminBlockTypeDialogue),
      ('AUDIO', Icons.graphic_eq, l10n.adminBlockTypeAudio),
      ('IMAGE', Icons.image_outlined, l10n.adminBlockTypeImage),
      ('VOCABULARY', Icons.translate_outlined, l10n.adminBlockTypeVocabulary),
      ('QUIZ', Icons.quiz_outlined, l10n.adminBlockTypeQuiz),
      ('PRONUNCIATION', Icons.mic_outlined, l10n.adminBlockTypePronunciation),
      ('EXERCISE', Icons.extension_outlined, l10n.adminBlockTypeExercise),
      ('VIDEO', Icons.videocam_outlined, l10n.adminBlockTypeVideo),
    ];

List<(String, String)> _aiActions(AppLocalizations l10n) => [
      ('GENERATE_EXAMPLES', l10n.adminAiActionGenerateExamples),
      ('CREATE_QUIZ', l10n.adminAiActionCreateQuiz),
      ('SIMPLIFY_CONTENT', l10n.adminAiActionSimplifyContent),
      ('CHECK_TRANSLATIONS', l10n.adminAiActionCheckTranslations),
    ];

class AdminLessonEditorScreen extends StatefulWidget {
  const AdminLessonEditorScreen({super.key, required this.lessonId, this.lessonTitle});

  final String lessonId;
  final String? lessonTitle;

  @override
  State<AdminLessonEditorScreen> createState() => _AdminLessonEditorScreenState();
}

class _AdminLessonEditorScreenState extends State<AdminLessonEditorScreen> {
  final repository = LessonEditorRepository();
  final contentRepository = ContentRepository();
  final adminRepository = AdminRepository();
  final knowledgeRepository = KnowledgeRepository();

  bool isLoading = true;
  LessonDetail? lesson;
  List<LessonBlock> blocks = [];
  List<LessonComment> comments = [];
  List<KnowledgeWord> vocabulary = [];
  List<AdminUser> staff = [];
  String? existingQuizId;

  bool aiLoading = false;
  String aiAction = 'GENERATE_EXAMPLES';
  final aiInstructionController = TextEditingController();
  String? aiSuggestion;
  List<Map<String, dynamic>>? aiQuizDraft;

  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    aiInstructionController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final fetchedLesson = await repository.getLesson(widget.lessonId);
      final results = await Future.wait([
        repository.getBlocks(widget.lessonId),
        repository.getComments(widget.lessonId),
        knowledgeRepository.getVocabulary(languageId: fetchedLesson.languageId),
        adminRepository.getUsers(),
        contentRepository.getQuizForLesson(widget.lessonId),
      ]);
      if (!mounted) return;
      setState(() {
        lesson = fetchedLesson;
        blocks = results[0] as List<LessonBlock>;
        comments = results[1] as List<LessonComment>;
        vocabulary = results[2] as List<KnowledgeWord>;
        staff = (results[3] as List<AdminUser>).where((u) => u.role == 'TEACHER' || u.role == 'ADMIN').toList();
        existingQuizId = (results[4] as AdminQuiz?)?.id;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addBlock(String type) async {
    final l10n = AppLocalizations.of(context);
    try {
      await repository.createBlock(
        lessonId: widget.lessonId,
        orderNumber: blocks.length + 1,
        type: type,
        quizId: type == 'QUIZ' ? existingQuizId : null,
      );
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotAddBlock));
    }
  }

  Future<void> _deleteBlock(LessonBlock block) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminRemoveBlockTitle),
        content: Text(l10n.adminRemoveBlockConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.adminRemoveButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    try {
      await repository.deleteBlock(block.id);
      await load();
    } on DioException catch (e) {
      if (!mounted) return;
      _showMessage(extractErrorMessage(e, fallback: AppLocalizations.of(context).adminCouldNotRemoveBlock));
    }
  }

  Future<void> _moveBlock(int index, int delta) async {
    final l10n = AppLocalizations.of(context);
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= blocks.length) return;
    final ids = blocks.map((b) => b.id).toList();
    final moved = ids.removeAt(index);
    ids.insert(newIndex, moved);
    try {
      await repository.reorderBlocks(widget.lessonId, ids);
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotReorderBlocks));
    }
  }

  Future<void> _submitForReview() async {
    final l10n = AppLocalizations.of(context);
    try {
      await contentRepository.updateLesson(widget.lessonId, status: 'IN_REVIEW');
      await load();
      _showMessage(l10n.adminSubmittedForReviewMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotSubmitForReview));
    }
  }

  Future<void> _assignReviewer(String? reviewerId) async {
    final l10n = AppLocalizations.of(context);
    try {
      await contentRepository.updateLesson(widget.lessonId, reviewerId: reviewerId ?? '');
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotAssignReviewer));
    }
  }

  Future<void> _postComment() async {
    final l10n = AppLocalizations.of(context);
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await repository.postComment(widget.lessonId, text);
      commentController.clear();
      final refreshed = await repository.getComments(widget.lessonId);
      if (!mounted) return;
      setState(() => comments = refreshed);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotPostComment));
    }
  }

  Future<void> _runAiAssist() async {
    if (lesson == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      aiLoading = true;
      aiSuggestion = null;
      aiQuizDraft = null;
    });
    try {
      final result = await repository.lessonAssist(
        action: aiAction,
        lessonContent: lesson!.content,
        frenchContent: lesson!.frenchContent,
        instruction: aiInstructionController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        aiSuggestion = result.suggestion;
        aiQuizDraft = result.quizDraft;
      });
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminNnangaNoRespondError));
    } finally {
      if (mounted) setState(() => aiLoading = false);
    }
  }

  Future<void> _applySuggestionAsTextBlock() async {
    if (aiSuggestion == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      await repository.createBlock(
        lessonId: widget.lessonId,
        orderNumber: blocks.length + 1,
        type: 'TEXT',
        titleLabel: l10n.adminNnangaSuggestionLabel,
        textContent: aiSuggestion,
      );
      await load();
      _showMessage(l10n.adminAddedAsTextBlockMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotApplySuggestion));
    }
  }

  Future<void> _applyQuizDraft() async {
    if (aiQuizDraft == null || existingQuizId == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      for (final question in aiQuizDraft!) {
        final choices = ((question['choices'] ?? []) as List)
            .map((c) => (
                  text: (c['text'] ?? '').toString(),
                  frenchText: null,
                  isCorrect: c['isCorrect'] == true,
                ))
            .toList();
        await contentRepository.createQuestionWithChoices(
          quizId: existingQuizId!,
          questionText: (question['questionText'] ?? '').toString(),
          choices: choices,
        );
      }
      _showMessage(l10n.adminDraftQuestionsAddedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotApplyQuizDraft));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminShell(
      activeNavKey: 'lessons',
      languageId: lesson?.languageId,
      languageName: lesson?.courseTitle,
      title: l10n.adminLessonEditorTitle,
      subtitle: widget.lessonTitle ?? lesson?.title ?? '',
      actions: [
        if (lesson != null && lesson!.status == 'DRAFT')
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _submitForReview,
            icon: const Icon(Icons.send_outlined, size: 16),
            label: Text(l10n.adminSubmitForReviewButton),
          ),
      ],
      child: isLoading
          ? const ShimmerListLoader(itemCount: 5, itemHeight: 100)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 200, child: _BlockPalette(onAdd: _addBlock)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(lesson?.title ?? '', style: AppTypography.title)),
                          StatusPill(status: lesson?.status ?? 'DRAFT'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (blocks.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
                          child: Text(
                            l10n.adminNoBlocksYetMessage,
                            style: AppTypography.caption,
                          ),
                        )
                      else
                        for (var i = 0; i < blocks.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _BlockCard(
                              key: ValueKey(blocks[i].id),
                              block: blocks[i],
                              index: i,
                              total: blocks.length,
                              vocabulary: vocabulary,
                              existingQuizId: existingQuizId,
                              lessonId: widget.lessonId,
                              repository: repository,
                              onMove: (delta) => _moveBlock(i, delta),
                              onDelete: () => _deleteBlock(blocks[i]),
                              onSaved: load,
                              onShowMessage: _showMessage,
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NnangaAssistantPanel(
                        action: aiAction,
                        onActionChanged: (v) => setState(() => aiAction = v),
                        instructionController: aiInstructionController,
                        loading: aiLoading,
                        suggestion: aiSuggestion,
                        quizDraft: aiQuizDraft,
                        hasQuiz: existingQuizId != null,
                        onAsk: _runAiAssist,
                        onApplySuggestion: _applySuggestionAsTextBlock,
                        onApplyQuizDraft: _applyQuizDraft,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ContentChecklistCard(blocks: blocks, lesson: lesson),
                      const SizedBox(height: AppSpacing.md),
                      _ReviewCollaborationCard(
                        lesson: lesson,
                        staff: staff,
                        comments: comments,
                        commentController: commentController,
                        onAssignReviewer: _assignReviewer,
                        onPostComment: _postComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _BlockPalette extends StatelessWidget {
  const _BlockPalette({required this.onAdd});
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminAddBlockTitle, style: AppTypography.title.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.md),
          for (final t in _blockTypes(l10n))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () => onAdd(t.$1),
                icon: Icon(t.$2, size: 18),
                label: Text(t.$3),
              ),
            ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatefulWidget {
  const _BlockCard({
    super.key,
    required this.block,
    required this.index,
    required this.total,
    required this.vocabulary,
    required this.existingQuizId,
    required this.lessonId,
    required this.repository,
    required this.onMove,
    required this.onDelete,
    required this.onSaved,
    required this.onShowMessage,
  });

  final LessonBlock block;
  final int index;
  final int total;
  final List<KnowledgeWord> vocabulary;
  final String? existingQuizId;
  final String lessonId;
  final LessonEditorRepository repository;
  final ValueChanged<int> onMove;
  final VoidCallback onDelete;
  final VoidCallback onSaved;
  final ValueChanged<String> onShowMessage;

  @override
  State<_BlockCard> createState() => _BlockCardState();
}

class _BlockCardState extends State<_BlockCard> {
  late final titleController = TextEditingController(text: widget.block.titleLabel);
  late final textController = TextEditingController(text: widget.block.textContent);
  late final frenchTextController = TextEditingController(text: widget.block.frenchTextContent);
  late final mediaUrlController = TextEditingController(text: widget.block.mediaUrl);
  late final exerciseJsonController =
      TextEditingController(text: widget.block.exerciseJson == null ? '' : jsonEncode(widget.block.exerciseJson));
  late String? vocabularyId = widget.block.vocabularyId;
  late List<Map<String, String>> turns = widget.block.dialogueJson
          ?.map((t) => {
                'speaker': (t['speaker'] ?? '').toString(),
                'text': (t['text'] ?? '').toString(),
                'frenchText': (t['frenchText'] ?? '').toString(),
              })
          .toList() ??
      [];
  bool isSaving = false;
  bool isUploading = false;

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    frenchTextController.dispose();
    mediaUrlController.dispose();
    exerciseJsonController.dispose();
    super.dispose();
  }

  IconData _icon(AppLocalizations l10n) {
    final types = _blockTypes(l10n);
    return types.firstWhere((t) => t.$1 == widget.block.type, orElse: () => types.first).$2;
  }

  String _label(AppLocalizations l10n) {
    final types = _blockTypes(l10n);
    return types.firstWhere((t) => t.$1 == widget.block.type, orElse: () => types.first).$3;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => isSaving = true);
    try {
      switch (widget.block.type) {
        case 'TEXT':
          await widget.repository.updateBlock(
            widget.block.id,
            titleLabel: titleController.text.trim(),
            textContent: textController.text.trim(),
            frenchTextContent: frenchTextController.text.trim(),
          );
        case 'DIALOGUE':
          await widget.repository.updateBlock(
            widget.block.id,
            dialogueJson: turns,
          );
        case 'AUDIO':
        case 'VIDEO':
          await widget.repository.updateBlock(
            widget.block.id,
            mediaUrl: mediaUrlController.text.trim(),
          );
        case 'IMAGE':
          await widget.repository.updateBlock(
            widget.block.id,
            titleLabel: titleController.text.trim(),
            textContent: textController.text.trim(),
            mediaUrl: mediaUrlController.text.trim(),
          );
        case 'VOCABULARY':
        case 'PRONUNCIATION':
          await widget.repository.updateBlock(
            widget.block.id,
            titleLabel: titleController.text.trim(),
            vocabularyId: vocabularyId ?? '',
          );
        case 'QUIZ':
          await widget.repository.updateBlock(
            widget.block.id,
            quizId: widget.existingQuizId ?? '',
          );
        case 'EXERCISE':
          Map<String, dynamic> parsed;
          try {
            parsed = exerciseJsonController.text.trim().isEmpty
                ? {}
                : Map<String, dynamic>.from(jsonDecode(exerciseJsonController.text) as Map);
          } catch (_) {
            widget.onShowMessage(l10n.adminExerciseInvalidJsonError);
            setState(() => isSaving = false);
            return;
          }
          await widget.repository.updateBlock(widget.block.id, exerciseJson: parsed);
      }
      widget.onSaved();
    } on DioException catch (e) {
      widget.onShowMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotSaveBlock));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _uploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final Uint8List bytes = await picked.readAsBytes();
    setState(() => isUploading = true);
    try {
      final url = await ContentRepository().uploadImage(bytes, picked.name);
      if (!mounted) return;
      setState(() => mediaUrlController.text = url);
    } on DioException catch (e) {
      widget.onShowMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotUploadImage));
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _uploadAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final picked = result.files.first;
    setState(() => isUploading = true);
    try {
      final url = await ContentRepository().uploadAudio(picked.bytes!, picked.name);
      if (!mounted) return;
      setState(() => mediaUrlController.text = url);
    } on DioException catch (e) {
      widget.onShowMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotUploadAudio));
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon(l10n), color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(_label(l10n), style: AppTypography.title.copyWith(fontSize: 15))),
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18),
                onPressed: widget.index == 0 ? null : () => widget.onMove(-1),
                tooltip: l10n.adminMoveUpTooltip,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: widget.index == widget.total - 1 ? null : () => widget.onMove(1),
                tooltip: l10n.adminMoveDownTooltip,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                onPressed: widget.onDelete,
                tooltip: l10n.adminRemoveBlockTooltip,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBody(l10n),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: isSaving ? null : _save,
              child: Text(isSaving ? l10n.adminSavingLabel : l10n.adminSaveBlockButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    switch (widget.block.type) {
      case 'TEXT':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.adminEyebrowLabelOptional)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: textController,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.adminFieldContent),
              contextMenuBuilder: markdownFormattingContextMenuBuilder(textController),
              onChanged: (_) => setState(() {}),
            ),
            const MarkdownHint(),
            LessonContentPreview(text: textController.text),
            TextField(
              controller: frenchTextController,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.adminFrenchContentOptionalLabel),
              contextMenuBuilder: markdownFormattingContextMenuBuilder(frenchTextController),
              onChanged: (_) => setState(() {}),
            ),
            const MarkdownHint(),
            LessonContentPreview(text: frenchTextController.text),
          ],
        );
      case 'DIALOGUE':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < turns.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: AppRadius.small),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: turns[i]['speaker'],
                              decoration: InputDecoration(labelText: l10n.adminSpeakerLabel),
                              onChanged: (v) => turns[i]['speaker'] = v,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => setState(() => turns.removeAt(i)),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: turns[i]['text'],
                        decoration: InputDecoration(labelText: l10n.adminLineLabel),
                        onChanged: (v) => turns[i]['text'] = v,
                      ),
                      TextFormField(
                        initialValue: turns[i]['frenchText'],
                        decoration: InputDecoration(labelText: l10n.adminFrenchLineOptionalLabel),
                        onChanged: (v) => turns[i]['frenchText'] = v,
                      ),
                    ],
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => setState(() => turns.add({'speaker': '', 'text': '', 'frenchText': ''})),
              icon: const Icon(Icons.add),
              label: Text(l10n.adminAddTurnButton),
            ),
          ],
        );
      case 'AUDIO':
        return Row(
          children: [
            Expanded(child: TextField(controller: mediaUrlController, decoration: InputDecoration(labelText: l10n.adminAudioUrlLabel))),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton(onPressed: isUploading ? null : _uploadAudio, child: Text(isUploading ? '...' : l10n.adminUploadButton)),
          ],
        );
      case 'VIDEO':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: mediaUrlController, decoration: InputDecoration(labelText: l10n.adminVideoUrlLabel)),
            const SizedBox(height: AppSpacing.xs),
            _noticeBanner(l10n.adminVideoNotVisibleNotice),
          ],
        );
      case 'IMAGE':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.adminWordLabelField)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(child: TextField(controller: mediaUrlController, decoration: InputDecoration(labelText: l10n.adminImageUrlLabel))),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(onPressed: isUploading ? null : _uploadImage, child: Text(isUploading ? '...' : l10n.adminUploadButton)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: textController, decoration: InputDecoration(labelText: l10n.adminCaptionOptionalLabel)),
          ],
        );
      case 'VOCABULARY':
      case 'PRONUNCIATION':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String?>(
              isExpanded: true,
              value: vocabularyId,
              hint: Text(l10n.adminSelectWordHint),
              items: [
                for (final w in widget.vocabulary) DropdownMenuItem(value: w.id, child: Text(w.word)),
              ],
              onChanged: (v) => setState(() => vocabularyId = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.adminInstructionsOptionalLabel)),
          ],
        );
      case 'QUIZ':
        return widget.existingQuizId == null
            ? _noticeBanner(l10n.adminNoQuizYetNotice)
            : Text(l10n.adminLinkedToQuizMessage, style: AppTypography.caption);
      case 'EXERCISE':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _noticeBanner(l10n.adminExerciseNotVisibleNotice),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: exerciseJsonController,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.adminExerciseDataJsonLabel),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _noticeBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: AppRadius.small),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTypography.caption)),
        ],
      ),
    );
  }
}

class _NnangaAssistantPanel extends StatelessWidget {
  const _NnangaAssistantPanel({
    required this.action,
    required this.onActionChanged,
    required this.instructionController,
    required this.loading,
    required this.suggestion,
    required this.quizDraft,
    required this.hasQuiz,
    required this.onAsk,
    required this.onApplySuggestion,
    required this.onApplyQuizDraft,
  });

  final String action;
  final ValueChanged<String> onActionChanged;
  final TextEditingController instructionController;
  final bool loading;
  final String? suggestion;
  final List<Map<String, dynamic>>? quizDraft;
  final bool hasQuiz;
  final VoidCallback onAsk;
  final VoidCallback onApplySuggestion;
  final VoidCallback onApplyQuizDraft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.ai, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.adminNnangaAssistantTitle, style: AppTypography.title.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final a in _aiActions(l10n))
                ChoiceChip(
                  label: Text(a.$2, style: const TextStyle(fontSize: 11)),
                  selected: action == a.$1,
                  onSelected: (_) => onActionChanged(a.$1),
                  selectedColor: AppColors.ai,
                  labelStyle: TextStyle(color: action == a.$1 ? Colors.white : AppColors.textPrimary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: instructionController,
            decoration: InputDecoration(hintText: l10n.adminNnangaInstructionHint),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.ai),
              onPressed: loading ? null : onAsk,
              child: Text(loading ? l10n.adminThinkingLabel : l10n.adminAskNnangaButton),
            ),
          ),
          if (suggestion != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: AppRadius.small),
              child: Text(suggestion!, style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (quizDraft != null && hasQuiz)
              OutlinedButton(onPressed: onApplyQuizDraft, child: Text(l10n.adminAddDraftQuestionsButton))
            else if (quizDraft == null)
              OutlinedButton(onPressed: onApplySuggestion, child: Text(l10n.adminApplyAsTextBlockButton)),
          ],
        ],
      ),
    );
  }
}

class _ContentChecklistCard extends StatelessWidget {
  const _ContentChecklistCard({required this.blocks, required this.lesson});

  final List<LessonBlock> blocks;
  final LessonDetail? lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasText = blocks.any((b) => b.type == 'TEXT') || (lesson?.content.isNotEmpty ?? false);
    final hasAudio = blocks.any((b) => b.type == 'AUDIO') || (lesson?.audioUrl?.isNotEmpty ?? false);
    final hasFrench = lesson?.frenchContent?.isNotEmpty ?? false;
    final hasQuiz = lesson?.hasQuiz ?? false;
    final checks = [hasText, hasAudio, hasFrench, hasQuiz];
    final percent = (checks.where((c) => c).length / checks.length * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminContentChecklistTitle, style: AppTypography.title.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.md),
          Center(child: ProgressRing(progress: percent / 100, centerLabel: '$percent%', subLabel: l10n.adminReadyLabel, size: 90)),
          const SizedBox(height: AppSpacing.md),
          _row(l10n.adminChecklistTextContent, hasText),
          _row(l10n.adminBlockTypeAudio, hasAudio),
          _row(l10n.adminChecklistFrenchTranslation, hasFrench),
          _row(l10n.adminChecklistQuizLinked, hasQuiz),
        ],
      ),
    );
  }

  Widget _row(String label, bool complete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(complete ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: complete ? AppColors.success : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTypography.caption)),
        ],
      ),
    );
  }
}

class _ReviewCollaborationCard extends StatelessWidget {
  const _ReviewCollaborationCard({
    required this.lesson,
    required this.staff,
    required this.comments,
    required this.commentController,
    required this.onAssignReviewer,
    required this.onPostComment,
  });

  final LessonDetail? lesson;
  final List<AdminUser> staff;
  final List<LessonComment> comments;
  final TextEditingController commentController;
  final ValueChanged<String?> onAssignReviewer;
  final VoidCallback onPostComment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminReviewCollaborationTitle, style: AppTypography.title.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.adminColReviewer, style: AppTypography.caption),
          const SizedBox(height: 4),
          DropdownButton<String?>(
            isExpanded: true,
            value: lesson?.reviewerId,
            hint: Text(l10n.commonUnassigned),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.commonUnassigned)),
              for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.fullName, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: onAssignReviewer,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.adminCommentsLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          if (comments.isEmpty)
            Text(l10n.adminNoCommentsYetMessage, style: AppTypography.caption)
          else
            ...comments.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        const SizedBox(width: AppSpacing.xs),
                        Text(DateFormat.MMMd().add_jm().format(c.createdAt), style: AppTypography.caption.copyWith(fontSize: 10)),
                      ],
                    ),
                    Text(c.text, style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(hintText: l10n.adminAddCommentHint),
                  onSubmitted: (_) => onPostComment(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send, size: 18, color: AppColors.primary), onPressed: onPostComment),
            ],
          ),
        ],
      ),
    );
  }
}
