import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/knowledge_repository.dart';
import '../domain/knowledge_models.dart';
import '../domain/vocabulary_paste_parser.dart';
import 'widgets/audio_recorder_field.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

/// Standalone top-level screen for the Vocabulary Management section.
class AdminVocabularyManagementScreen extends StatelessWidget {
  const AdminVocabularyManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: l10n.adminVocabMgmtTitle, colors: const [AppColors.ai, Color(0xFF6B4CE0)]),
      body: SafeArea(child: VocabularyManagerBody(languageId: languageId)),
    );
  }
}

/// The vocabulary CRUD list + FAB, reused as the body of the standalone
/// screen above and as a tab inside "Train the AI" (this is Nnanga's
/// knowledge base — the two surfaces edit the exact same data).
class VocabularyManagerBody extends StatefulWidget {
  const VocabularyManagerBody({super.key, required this.languageId});

  final String languageId;

  @override
  State<VocabularyManagerBody> createState() => _VocabularyManagerBodyState();
}

class _VocabularyManagerBodyState extends State<VocabularyManagerBody> {
  final repository = KnowledgeRepository();
  final searchController = TextEditingController();
  bool isLoading = true;
  List<KnowledgeWord> words = [];
  List<KnowledgeText> texts = [];
  String? difficultyFilter;

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
      final results = await Future.wait([
        repository.getVocabulary(languageId: widget.languageId),
        repository.getKnowledgeTexts(languageId: widget.languageId),
      ]);
      if (!mounted) return;
      setState(() {
        words = results[0] as List<KnowledgeWord>;
        texts = results[1] as List<KnowledgeText>;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<KnowledgeWord> get _visibleWords {
    final query = searchController.text.trim().toLowerCase();
    return words.where((w) {
      final matchesDifficulty = difficultyFilter == null || w.difficulty == difficultyFilter;
      final matchesQuery = query.isEmpty || w.word.toLowerCase().contains(query);
      return matchesDifficulty && matchesQuery;
    }).toList();
  }

  List<KnowledgeText> get _visibleTexts {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return texts;
    return texts.where((t) {
      return t.text.toLowerCase().contains(query) ||
          (t.translation?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// A search query or difficulty chip left over from browsing can silently
  /// hide content that was just added — it's created successfully server-side
  /// but filtered out of `_visibleWords`/`_visibleTexts` with no obvious sign
  /// why. Clearing both after a successful add/import guarantees the admin
  /// actually sees what they just entered.
  void _clearFilters() {
    searchController.clear();
    setState(() => difficultyFilter = null);
  }

  Future<void> deleteWord(KnowledgeWord word) async {
    try {
      await repository.deleteVocabulary(word.id);
      load();
    } on DioException catch (e) {
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminVocabMgmtCouldNotDeleteWord));
    }
  }

  Future<void> addWord() async {
    final result = await showDialog<VocabFormResult>(
      context: context,
      builder: (context) => const VocabFormDialog(),
    );
    if (result == null) return;

    try {
      await repository.createVocabulary(
        word: result.word,
        languageId: widget.languageId,
        englishMeaning: result.englishMeaning,
        frenchMeaning: result.frenchMeaning,
        exampleSentence: result.exampleSentence,
        exampleTranslation: result.exampleTranslation,
        frenchExampleTranslation: result.frenchExampleTranslation,
        difficulty: result.difficulty,
        phoneticTranscription: result.phoneticTranscription,
        audioUrl: result.audioUrl,
      );
      _clearFilters();
      load();
      final l10n = AppLocalizations.of(context);
      _showMessage(l10n.adminVocabMgmtWordAdded);
    } on DioException catch (e) {
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminVocabMgmtCouldNotAddWord));
    }
  }

  Future<void> pasteVocabulary() async {
    final parsedWords = await showDialog<List<ParsedVocabWord>>(
      context: context,
      builder: (context) => const _PasteVocabularyDialog(),
    );
    if (parsedWords == null || parsedWords.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    var succeeded = 0;
    var failed = 0;
    String? firstError;
    for (final w in parsedWords) {
      try {
        await repository.createVocabulary(
          word: w.word,
          languageId: widget.languageId,
          englishMeaning: w.englishMeaning,
          frenchMeaning: w.frenchMeaning,
          exampleSentence: w.exampleSentence,
          exampleTranslation: w.exampleTranslation,
          frenchExampleTranslation: w.frenchExampleTranslation,
          difficulty: w.difficulty,
          phoneticTranscription: w.phoneticTranscription,
        );
        succeeded++;
      } on DioException catch (e) {
        failed++;
        firstError ??= extractErrorMessage(e, fallback: l10n.adminVocabMgmtUnknownServerError);
      } catch (e) {
        failed++;
        firstError ??= e.toString();
      }
    }

    _clearFilters();
    load();
    _showMessage(
      failed == 0
          ? l10n.adminVocabMgmtImportedWords(succeeded)
          : l10n.adminVocabMgmtImportedWordsWithFailures(succeeded, failed) +
                (firstError != null ? ' — $firstError' : '') +
                '.',
    );
  }

  Future<void> editWord(KnowledgeWord word) async {
    final result = await showDialog<VocabFormResult>(
      context: context,
      builder: (context) => VocabFormDialog(initial: word),
    );
    if (result == null) return;

    try {
      await repository.updateVocabulary(
        word.id,
        word: result.word,
        englishMeaning: result.englishMeaning,
        frenchMeaning: result.frenchMeaning,
        exampleSentence: result.exampleSentence,
        exampleTranslation: result.exampleTranslation,
        frenchExampleTranslation: result.frenchExampleTranslation,
        difficulty: result.difficulty,
        phoneticTranscription: result.phoneticTranscription,
        audioUrl: result.audioUrl,
      );
      load();
      final l10n = AppLocalizations.of(context);
      _showMessage(l10n.adminVocabMgmtWordUpdated);
    } on DioException catch (e) {
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminVocabMgmtCouldNotUpdateWord));
    }
  }

  Future<void> deleteText(KnowledgeText text) async {
    try {
      await repository.deleteKnowledgeText(text.id);
      load();
    } on DioException catch (e) {
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminVocabMgmtCouldNotDeleteText));
    }
  }

  Future<void> addText() async {
    final result = await showDialog<TextEntryFormResult>(
      context: context,
      builder: (context) => const TextEntryFormDialog(),
    );
    if (result == null) return;

    try {
      await repository.createKnowledgeText(
        text: result.text,
        languageId: widget.languageId,
        translation: result.translation,
      );
      _clearFilters();
      load();
      final l10n = AppLocalizations.of(context);
      _showMessage(l10n.adminVocabMgmtTextAdded);
    } on DioException catch (e) {
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminVocabMgmtCouldNotAddText));
    }
  }

  Future<void> editText(KnowledgeText text) async {
    final result = await showDialog<TextEntryFormResult>(
      context: context,
      builder: (context) => TextEntryFormDialog(initial: text),
    );
    if (result == null) return;

    try {
      await repository.updateKnowledgeText(
        text.id,
        text: result.text,
        translation: result.translation,
      );
      load();
      final l10n = AppLocalizations.of(context);
      _showMessage(l10n.adminVocabMgmtTextUpdated);
    } on DioException catch (e) {
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminVocabMgmtCouldNotUpdateText));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addText',
            backgroundColor: const Color(0xFF6B4CE0),
            icon: const Icon(Icons.article_outlined, color: Colors.white),
            label: Text(l10n.adminVocabMgmtAddTextAction, style: const TextStyle(color: Colors.white)),
            onPressed: addText,
          ),
          const SizedBox(height: AppSpacing.md),
          FloatingActionButton.extended(
            heroTag: 'pasteVocabulary',
            backgroundColor: AppColors.secondary,
            icon: const Icon(Icons.content_paste, color: Colors.white),
            label: Text(l10n.adminVocabMgmtPasteVocabularyAction, style: const TextStyle(color: Colors.white)),
            onPressed: pasteVocabulary,
          ),
          const SizedBox(height: AppSpacing.md),
          FloatingActionButton.extended(
            heroTag: 'addWord',
            backgroundColor: AppColors.ai,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(l10n.adminVocabMgmtAddKnowledgeAction, style: const TextStyle(color: Colors.white)),
            onPressed: addWord,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminVocabMgmtKnowledgeBaseDescription,
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.adminVocabMgmtSearchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: l10n.adminVocabMgmtAllLevels,
                    selected: difficultyFilter == null,
                    onTap: () => setState(() => difficultyFilter = null),
                  ),
                  ..._levels.map(
                    (l) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: _FilterChip(
                        label: l[0] + l.substring(1).toLowerCase(),
                        selected: difficultyFilter == l,
                        onTap: () => setState(() => difficultyFilter = l),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: isLoading
                  ? const ShimmerListLoader()
                  : (_visibleWords.isEmpty && _visibleTexts.isEmpty)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                            child: Text(
                              l10n.adminVocabMgmtEmptyState,
                              style: AppTypography.caption,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 200),
                          children: [
                            if (_visibleTexts.isNotEmpty) ...[
                              SectionTitle(
                                title: l10n.adminVocabMgmtTextsSectionTitle,
                                subtitle: l10n.adminVocabMgmtEntriesCount(_visibleTexts.length),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ..._visibleTexts.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () => editText(item),
                                    child: PremiumCard(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6B4CE0).withValues(alpha: 0.12),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.article_outlined,
                                              color: Color(0xFF6B4CE0),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item.text, style: AppTypography.body),
                                                if (item.translation != null && item.translation!.isNotEmpty) ...[
                                                  const SizedBox(height: AppSpacing.xs),
                                                  Text(item.translation!, style: AppTypography.caption),
                                                ],
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined),
                                            tooltip: l10n.adminVocabMgmtEditTooltip,
                                            onPressed: () => editText(item),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                            tooltip: l10n.adminVocabMgmtDeleteTooltip,
                                            onPressed: () => deleteText(item),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              SectionTitle(
                                title: l10n.adminVocabMgmtVocabularySectionTitle,
                                subtitle: l10n.adminVocabMgmtWordsCount(_visibleWords.length),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            ..._visibleWords.map(
                              (word) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => editWord(word),
                                  child: PremiumCard(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppColors.ai.withValues(alpha: 0.12),
                                          child: Text(
                                            word.word.isNotEmpty ? word.word[0].toUpperCase() : '?',
                                            style: const TextStyle(color: AppColors.ai, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(word.word, style: AppTypography.title),
                                              if (word.englishMeaning != null && word.englishMeaning!.isNotEmpty)
                                                Text(word.englishMeaning!, style: AppTypography.caption),
                                            ],
                                          ),
                                        ),
                                        Chip(
                                          label: Text(word.difficulty, style: const TextStyle(fontSize: 11)),
                                          backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              editWord(word);
                                            } else if (value == 'delete') {
                                              deleteWord(word);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text(l10n.adminVocabMgmtEditAction),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text(l10n.adminVocabMgmtDeleteAction, style: const TextStyle(color: AppColors.error)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.ai,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
    );
  }
}

class VocabFormResult {
  const VocabFormResult({
    required this.word,
    this.englishMeaning,
    this.frenchMeaning,
    this.exampleSentence,
    this.exampleTranslation,
    this.frenchExampleTranslation,
    required this.difficulty,
    this.phoneticTranscription,
    this.audioUrl,
  });

  final String word;
  final String? englishMeaning;
  final String? frenchMeaning;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? frenchExampleTranslation;
  final String difficulty;
  final String? phoneticTranscription;
  final String? audioUrl;
}

class VocabFormDialog extends StatefulWidget {
  const VocabFormDialog({super.key, this.initial});

  /// When set, the dialog opens pre-filled for editing instead of adding.
  final KnowledgeWord? initial;

  @override
  State<VocabFormDialog> createState() => _VocabFormDialogState();
}

class _VocabFormDialogState extends State<VocabFormDialog> {
  late final wordController = TextEditingController(text: widget.initial?.word ?? '');
  late final englishController = TextEditingController(text: widget.initial?.englishMeaning ?? '');
  late final frenchController = TextEditingController(text: widget.initial?.frenchMeaning ?? '');
  late final exampleController = TextEditingController(text: widget.initial?.exampleSentence ?? '');
  late final translationController =
      TextEditingController(text: widget.initial?.exampleTranslation ?? '');
  late final frenchTranslationController =
      TextEditingController(text: widget.initial?.frenchExampleTranslation ?? '');
  late final phoneticController =
      TextEditingController(text: widget.initial?.phoneticTranscription ?? '');
  late String difficulty = widget.initial?.difficulty.isNotEmpty == true
      ? widget.initial!.difficulty
      : 'BEGINNER';
  late String? audioUrl = widget.initial?.audioUrl;

  @override
  void dispose() {
    wordController.dispose();
    englishController.dispose();
    frenchController.dispose();
    exampleController.dispose();
    translationController.dispose();
    frenchTranslationController.dispose();
    phoneticController.dispose();
    super.dispose();
  }

  Widget _tableColumn(String label, TextEditingController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(isEditing ? l10n.adminVocabMgmtEditKnowledgeEntryTitle : l10n.adminVocabMgmtAddKnowledgeEntryTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tableColumn(l10n.adminVocabMgmtEwondoWordLabel, wordController),
                  const SizedBox(width: AppSpacing.md),
                  _tableColumn(l10n.adminVocabMgmtExampleSentenceLabel, exampleController),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.adminVocabMgmtPhoneticLabel,
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: phoneticController,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surface,
                  hintText: l10n.adminVocabMgmtPhoneticHint,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AudioRecorderField(
                initialUrl: audioUrl,
                onChanged: (url) => audioUrl = url,
                label: l10n.adminVocabMgmtPronunciationAudioLabel,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tableColumn(l10n.adminVocabMgmtEnglishMeaningLabel, englishController),
                  const SizedBox(width: AppSpacing.md),
                  _tableColumn(l10n.adminVocabMgmtEnglishTranslationLabel, translationController),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tableColumn(l10n.adminVocabMgmtFrenchMeaningLabel, frenchController),
                  const SizedBox(width: AppSpacing.md),
                  _tableColumn(l10n.adminVocabMgmtFrenchTranslationLabel, frenchTranslationController),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.adminVocabMgmtDifficultyLabel, style: AppTypography.caption),
              Wrap(
                spacing: AppSpacing.sm,
                children: _levels
                    .map((l) => ChoiceChip(
                          label: Text(l),
                          selected: difficulty == l,
                          onSelected: (_) => setState(() => difficulty = l),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.adminVocabMgmtCancel)),
        FilledButton(
          onPressed: () {
            if (wordController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              VocabFormResult(
                word: wordController.text.trim(),
                englishMeaning: englishController.text.trim(),
                frenchMeaning: frenchController.text.trim(),
                exampleSentence: exampleController.text.trim(),
                exampleTranslation: translationController.text.trim(),
                frenchExampleTranslation: frenchTranslationController.text.trim(),
                difficulty: difficulty,
                phoneticTranscription: phoneticController.text.trim(),
                audioUrl: audioUrl,
              ),
            );
          },
          child: Text(isEditing ? l10n.adminVocabMgmtSave : l10n.adminVocabMgmtAdd),
        ),
      ],
    );
  }
}

class TextEntryFormResult {
  const TextEntryFormResult({required this.text, this.translation});

  final String text;
  final String? translation;
}

/// A separate knowledge type from [VocabFormDialog]'s single word/phrase
/// table: a longer block of Ewondo text (a proverb, story, cultural note)
/// paired with its translation, for feeding Nnanga content that doesn't fit
/// the word-oriented Vocabulary shape.
class TextEntryFormDialog extends StatefulWidget {
  const TextEntryFormDialog({super.key, this.initial});

  /// When set, the dialog opens pre-filled for editing instead of adding.
  final KnowledgeText? initial;

  @override
  State<TextEntryFormDialog> createState() => _TextEntryFormDialogState();
}

class _TextEntryFormDialogState extends State<TextEntryFormDialog> {
  late final textController = TextEditingController(text: widget.initial?.text ?? '');
  late final translationController =
      TextEditingController(text: widget.initial?.translation ?? '');

  @override
  void dispose() {
    textController.dispose();
    translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(isEditing ? l10n.adminVocabMgmtEditTextEntryTitle : l10n.adminVocabMgmtAddTextEntryTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(labelText: l10n.adminVocabMgmtEwondoTextLabel),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: translationController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(labelText: l10n.adminVocabMgmtTranslationLabel),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.adminVocabMgmtCancel)),
        FilledButton(
          onPressed: () {
            if (textController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              TextEntryFormResult(
                text: textController.text.trim(),
                translation: translationController.text.trim(),
              ),
            );
          },
          child: Text(isEditing ? l10n.adminVocabMgmtSave : l10n.adminVocabMgmtAdd),
        ),
      ],
    );
  }
}

/// Lets an admin paste a whole word list as plain text, previews how it
/// was parsed, and hands back the list to import — one [KnowledgeRepository
/// .createVocabulary] call per word, the same shape [addWord] already sends
/// for a single manually-entered word.
class _PasteVocabularyDialog extends StatefulWidget {
  const _PasteVocabularyDialog();

  @override
  State<_PasteVocabularyDialog> createState() => _PasteVocabularyDialogState();
}

class _PasteVocabularyDialogState extends State<_PasteVocabularyDialog> {
  final textController = TextEditingController();
  VocabularyPasteParseResult? result;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void parse() {
    setState(() => result = parseVocabularyPaste(textController.text));
  }

  void backToPaste() {
    setState(() => result = null);
  }

  @override
  Widget build(BuildContext context) {
    final current = result;
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(current == null ? l10n.adminVocabMgmtPasteVocabularyTitle : l10n.adminVocabMgmtPreviewImportTitle),
      content: SizedBox(
        width: 520,
        child: current == null ? _buildPasteStep(l10n) : _buildPreviewStep(current, l10n),
      ),
      actions: current == null
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.adminVocabMgmtCancel),
              ),
              FilledButton(
                onPressed: textController.text.trim().isEmpty ? null : parse,
                child: Text(l10n.adminVocabMgmtParseAction),
              ),
            ]
          : [
              TextButton(onPressed: backToPaste, child: Text(l10n.adminVocabMgmtBackAction)),
              FilledButton(
                onPressed: current.words.where((w) => w.isValid).isEmpty
                    ? null
                    : () => Navigator.pop(
                        context,
                        current.words.where((w) => w.isValid).toList(),
                      ),
                child: Text(
                  l10n.adminVocabMgmtImportWordsAction(current.words.where((w) => w.isValid).length),
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
            l10n.adminVocabMgmtPasteInstructions,
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
              'mendim | water | eau\n'
              'abé | house | maison\n'
              '\n'
              'nnom\n'
              'EN: man\n'
              'FR: homme\n'
              'Example: Nnom a ne mbem.\n'
              'Example EN: The man is strong.\n'
              'Phonetic: /nnɔm/\n'
              'Level: INTERMEDIATE',
              style: AppTypography.caption.copyWith(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.adminVocabMgmtPasteFormatHelp,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: textController,
            maxLines: 12,
            minLines: 8,
            decoration: InputDecoration(
              hintText: l10n.adminVocabMgmtPasteFieldHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep(VocabularyPasteParseResult result, AppLocalizations l10n) {
    final validCount = result.words.where((w) => w.isValid).length;
    return SizedBox(
      height: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminVocabMgmtWordsDetectedSummary(result.words.length, validCount),
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
            child: result.words.isEmpty
                ? Center(
                    child: Text(
                      l10n.adminVocabMgmtNothingToPreview,
                      style: AppTypography.caption,
                    ),
                  )
                : ListView.separated(
                    itemCount: result.words.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final w = result.words[index];
                      return Opacity(
                        opacity: w.isValid ? 1 : 0.5,
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      w.word,
                                      style: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(w.difficulty, style: const TextStyle(fontSize: 11)),
                                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                                  ),
                                ],
                              ),
                              if (w.englishMeaning != null || w.frenchMeaning != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    [
                                      if (w.englishMeaning != null) 'EN: ${w.englishMeaning}',
                                      if (w.frenchMeaning != null) 'FR: ${w.frenchMeaning}',
                                    ].join('   '),
                                    style: AppTypography.caption,
                                  ),
                                ),
                              if (w.exampleSentence != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    w.exampleSentence!,
                                    style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              if (w.warnings.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Text(
                                    w.warnings.join(' '),
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
