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
import '../data/knowledge_repository.dart';
import '../domain/knowledge_models.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

/// Standalone top-level screen for the Vocabulary Management section.
class AdminVocabularyManagementScreen extends StatelessWidget {
  const AdminVocabularyManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Vocabulary Management', colors: [AppColors.ai, Color(0xFF6B4CE0)]),
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

  Future<void> deleteWord(KnowledgeWord word) async {
    try {
      await repository.deleteVocabulary(word.id);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete word.'));
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
      );
      load();
      _showMessage('Knowledge entry added.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add word.'));
    }
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
      );
      load();
      _showMessage('Knowledge entry updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update word.'));
    }
  }

  Future<void> deleteText(KnowledgeText text) async {
    try {
      await repository.deleteKnowledgeText(text.id);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete text.'));
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
      load();
      _showMessage('Text & translation added.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add text.'));
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
      _showMessage('Text & translation updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update text.'));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            label: const Text('Add Text & Translation', style: TextStyle(color: Colors.white)),
            onPressed: addText,
          ),
          const SizedBox(height: AppSpacing.md),
          FloatingActionButton.extended(
            heroTag: 'addWord',
            backgroundColor: AppColors.ai,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Knowledge', style: TextStyle(color: Colors.white)),
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
              'This is Nnanga\'s knowledge base. It searches these words and their '
              'lessons to answer learners — the more you add, the better it answers.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search knowledge...',
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
                    label: 'All Levels',
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
                      ? Center(child: Text('No knowledge found.', style: AppTypography.caption))
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 140),
                          children: [
                            if (_visibleTexts.isNotEmpty) ...[
                              SectionTitle(
                                title: 'Texts & Translations',
                                subtitle: '${_visibleTexts.length} entries',
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
                                            tooltip: 'Edit',
                                            onPressed: () => editText(item),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                            tooltip: 'Delete',
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
                                title: 'Vocabulary',
                                subtitle: '${_visibleWords.length} words',
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
                                          itemBuilder: (context) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete', style: TextStyle(color: AppColors.error)),
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
  });

  final String word;
  final String? englishMeaning;
  final String? frenchMeaning;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? frenchExampleTranslation;
  final String difficulty;
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
  late String difficulty = widget.initial?.difficulty.isNotEmpty == true
      ? widget.initial!.difficulty
      : 'BEGINNER';

  @override
  void dispose() {
    wordController.dispose();
    englishController.dispose();
    frenchController.dispose();
    exampleController.dispose();
    translationController.dispose();
    frenchTranslationController.dispose();
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

    return AlertDialog(
      title: Text(isEditing ? 'Edit Knowledge Entry' : 'Add Knowledge Entry'),
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
                  _tableColumn('Ewondo word or phrase', wordController),
                  const SizedBox(width: AppSpacing.md),
                  _tableColumn('Example sentence', exampleController),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tableColumn('English meaning', englishController),
                  const SizedBox(width: AppSpacing.md),
                  _tableColumn('English translation', translationController),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tableColumn('French meaning', frenchController),
                  const SizedBox(width: AppSpacing.md),
                  _tableColumn('French translation', frenchTranslationController),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Difficulty', style: AppTypography.caption),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
              ),
            );
          },
          child: Text(isEditing ? 'Save' : 'Add'),
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

    return AlertDialog(
      title: Text(isEditing ? 'Edit Text & Translation' : 'Add Text & Translation'),
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
                decoration: const InputDecoration(labelText: 'Ewondo text'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: translationController,
                maxLines: 5,
                minLines: 3,
                decoration: const InputDecoration(labelText: 'Translation'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
