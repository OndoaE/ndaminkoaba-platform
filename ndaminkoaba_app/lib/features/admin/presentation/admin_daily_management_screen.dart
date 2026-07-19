import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/knowledge_repository.dart';
import '../domain/knowledge_models.dart';

const _dailyAccent = Color(0xFFC77B2E);

/// Manages the rotating pools behind the learner dashboard's Daily Word and
/// Daily Verse cards. Which entry is "today's" is computed on the backend
/// from the date, so admins only ever add/edit/remove pool entries here —
/// never need to pick "today's" item by hand.
class AdminDailyManagementScreen extends StatefulWidget {
  const AdminDailyManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminDailyManagementScreen> createState() => _AdminDailyManagementScreenState();
}

class _AdminDailyManagementScreenState extends State<AdminDailyManagementScreen> {
  final repository = KnowledgeRepository();
  final searchController = TextEditingController();

  bool isWordsMode = true;
  bool isLoading = true;
  List<DailyWordEntry> words = [];
  List<DailyVerseEntry> verses = [];

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
        repository.getDailyWords(languageId: widget.languageId),
        repository.getDailyVerses(languageId: widget.languageId),
      ]);
      if (!mounted) return;
      setState(() {
        words = results[0] as List<DailyWordEntry>;
        verses = results[1] as List<DailyVerseEntry>;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<DailyWordEntry> get _visibleWords {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return words;
    return words.where((w) => w.word.toLowerCase().contains(query)).toList();
  }

  List<DailyVerseEntry> get _visibleVerses {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return verses;
    return verses.where((v) {
      return v.text.toLowerCase().contains(query) ||
          v.reference.toLowerCase().contains(query);
    }).toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> addWord() async {
    final picked = await showDialog<KnowledgeWord>(
      context: context,
      builder: (context) => _VocabularyPickerDialog(languageId: widget.languageId),
    );
    if (picked == null) return;

    final result = await showDialog<DailyWordFormResult>(
      context: context,
      builder: (context) => DailyWordFormDialog(
        prefillWord: picked.word,
        prefillEnglishMeaning: picked.englishMeaning,
        prefillFrenchMeaning: picked.frenchMeaning,
        prefillUsageHint: picked.exampleSentence,
      ),
    );
    if (result == null) return;

    try {
      await repository.createDailyWord(
        word: result.word,
        languageId: widget.languageId,
        englishMeaning: result.englishMeaning,
        frenchMeaning: result.frenchMeaning,
        usageHint: result.usageHint,
      );
      load();
      _showMessage('Daily word added.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add daily word.'));
    }
  }

  Future<void> editWord(DailyWordEntry word) async {
    final result = await showDialog<DailyWordFormResult>(
      context: context,
      builder: (context) => DailyWordFormDialog(initial: word),
    );
    if (result == null) return;

    try {
      await repository.updateDailyWord(
        word.id,
        word: result.word,
        englishMeaning: result.englishMeaning,
        frenchMeaning: result.frenchMeaning,
        usageHint: result.usageHint,
      );
      load();
      _showMessage('Daily word updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update daily word.'));
    }
  }

  Future<void> deleteWord(DailyWordEntry word) async {
    try {
      await repository.deleteDailyWord(word.id);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete daily word.'));
    }
  }

  Future<void> addVerse() async {
    final picked = await showDialog<BibleVerseEntry>(
      context: context,
      builder: (context) => _BibleVersePickerDialog(languageId: widget.languageId),
    );
    if (picked == null) return;

    final result = await showDialog<DailyVerseFormResult>(
      context: context,
      builder: (context) => DailyVerseFormDialog(
        prefillText: picked.text,
        prefillEnglishText: picked.englishText,
        prefillFrenchText: picked.frenchText,
        prefillReference: '${picked.book} ${picked.chapter}:${picked.verse}',
      ),
    );
    if (result == null) return;

    try {
      await repository.createDailyVerse(
        text: result.text,
        languageId: widget.languageId,
        englishText: result.englishText,
        frenchText: result.frenchText,
        reference: result.reference,
      );
      load();
      _showMessage('Daily verse added.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add daily verse.'));
    }
  }

  Future<void> editVerse(DailyVerseEntry verse) async {
    final result = await showDialog<DailyVerseFormResult>(
      context: context,
      builder: (context) => DailyVerseFormDialog(initial: verse),
    );
    if (result == null) return;

    try {
      await repository.updateDailyVerse(
        verse.id,
        text: result.text,
        englishText: result.englishText,
        frenchText: result.frenchText,
        reference: result.reference,
      );
      load();
      _showMessage('Daily verse updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update daily verse.'));
    }
  }

  Future<void> deleteVerse(DailyVerseEntry verse) async {
    try {
      await repository.deleteDailyVerse(verse.id);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete daily verse.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(
        title: 'Daily Content Management',
        colors: [_dailyAccent, Color(0xFFE0A64F)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _dailyAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isWordsMode ? 'Add Daily Word' : 'Add Daily Verse',
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: isWordsMode ? addWord : addVerse,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A different entry from each pool is shown automatically every day on '
                'the learner dashboard — no need to pick "today\'s" item by hand.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('Daily Words'),
                    selected: isWordsMode,
                    onSelected: (_) => setState(() => isWordsMode = true),
                    selectedColor: _dailyAccent,
                    labelStyle: TextStyle(color: isWordsMode ? Colors.white : AppColors.textPrimary),
                  ),
                  ChoiceChip(
                    label: const Text('Daily Verses'),
                    selected: !isWordsMode,
                    onSelected: (_) => setState(() => isWordsMode = false),
                    selectedColor: _dailyAccent,
                    labelStyle: TextStyle(color: !isWordsMode ? Colors.white : AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isWordsMode ? 'Search Ewondo words...' : 'Search verses or reference...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const ShimmerListLoader(itemCount: 5, itemHeight: 80)
                    : isWordsMode
                        ? _buildWordsList()
                        : _buildVersesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordsList() {
    final visible = _visibleWords;
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.auto_awesome,
        iconColor: _dailyAccent,
        title: 'No daily words yet',
        message: 'Add Ewondo words to rotate through on the learner dashboard.',
      );
    }

    return ListView.separated(
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final word = visible[index];
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => editWord(word),
          child: PremiumCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _dailyAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.auto_awesome, color: _dailyAccent, size: 20),
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
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersesList() {
    final visible = _visibleVerses;
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.auto_stories,
        iconColor: _dailyAccent,
        title: 'No daily verses yet',
        message: 'Add Ewondo Bible verses to rotate through on the learner dashboard.',
      );
    }

    return ListView.separated(
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final verse = visible[index];
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => editVerse(verse),
          child: PremiumCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _dailyAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.auto_stories, color: _dailyAccent, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse.reference,
                        style: AppTypography.title.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        verse.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      editVerse(verse);
                    } else if (value == 'delete') {
                      deleteVerse(verse);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DailyWordFormResult {
  const DailyWordFormResult({
    required this.word,
    this.englishMeaning,
    this.frenchMeaning,
    this.usageHint,
  });

  final String word;
  final String? englishMeaning;
  final String? frenchMeaning;
  final String? usageHint;
}

class DailyWordFormDialog extends StatefulWidget {
  const DailyWordFormDialog({
    super.key,
    this.initial,
    this.prefillWord,
    this.prefillEnglishMeaning,
    this.prefillFrenchMeaning,
    this.prefillUsageHint,
  });

  /// Non-null only when truly editing an existing daily word (controls the
  /// dialog title/button and which record gets updated by the caller).
  final DailyWordEntry? initial;

  /// Values proposed from a picked [KnowledgeWord] when adding a brand new
  /// daily word — still fully editable before saving, and doesn't put the
  /// dialog into "editing" mode.
  final String? prefillWord;
  final String? prefillEnglishMeaning;
  final String? prefillFrenchMeaning;
  final String? prefillUsageHint;

  @override
  State<DailyWordFormDialog> createState() => _DailyWordFormDialogState();
}

class _DailyWordFormDialogState extends State<DailyWordFormDialog> {
  late final ewondoController =
      TextEditingController(text: widget.initial?.word ?? widget.prefillWord ?? '');
  late final englishController = TextEditingController(
      text: widget.initial?.englishMeaning ?? widget.prefillEnglishMeaning ?? '');
  late final frenchController = TextEditingController(
      text: widget.initial?.frenchMeaning ?? widget.prefillFrenchMeaning ?? '');
  late final usageController =
      TextEditingController(text: widget.initial?.usageHint ?? widget.prefillUsageHint ?? '');

  @override
  void dispose() {
    ewondoController.dispose();
    englishController.dispose();
    frenchController.dispose();
    usageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Daily Word' : 'Add Daily Word'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ewondoController,
                decoration: const InputDecoration(labelText: 'Ewondo word'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: englishController,
                decoration: const InputDecoration(labelText: 'English meaning'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: frenchController,
                decoration: const InputDecoration(labelText: 'French meaning'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: usageController,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(labelText: 'Usage hint (optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (ewondoController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              DailyWordFormResult(
                word: ewondoController.text.trim(),
                englishMeaning: englishController.text.trim(),
                frenchMeaning: frenchController.text.trim(),
                usageHint: usageController.text.trim(),
              ),
            );
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class DailyVerseFormResult {
  const DailyVerseFormResult({
    required this.text,
    this.englishText,
    this.frenchText,
    required this.reference,
  });

  final String text;
  final String? englishText;
  final String? frenchText;
  final String reference;
}

class DailyVerseFormDialog extends StatefulWidget {
  const DailyVerseFormDialog({
    super.key,
    this.initial,
    this.prefillText,
    this.prefillEnglishText,
    this.prefillFrenchText,
    this.prefillReference,
  });

  /// Non-null only when truly editing an existing daily verse (controls the
  /// dialog title/button and which record gets updated by the caller).
  final DailyVerseEntry? initial;

  /// Values proposed from a picked [BibleVerseEntry] when adding a brand
  /// new daily verse — still fully editable before saving, and doesn't put
  /// the dialog into "editing" mode.
  final String? prefillText;
  final String? prefillEnglishText;
  final String? prefillFrenchText;
  final String? prefillReference;

  @override
  State<DailyVerseFormDialog> createState() => _DailyVerseFormDialogState();
}

class _DailyVerseFormDialogState extends State<DailyVerseFormDialog> {
  late final referenceController =
      TextEditingController(text: widget.initial?.reference ?? widget.prefillReference ?? '');
  late final ewondoController =
      TextEditingController(text: widget.initial?.text ?? widget.prefillText ?? '');
  late final englishController = TextEditingController(
      text: widget.initial?.englishText ?? widget.prefillEnglishText ?? '');
  late final frenchController =
      TextEditingController(text: widget.initial?.frenchText ?? widget.prefillFrenchText ?? '');

  @override
  void dispose() {
    referenceController.dispose();
    ewondoController.dispose();
    englishController.dispose();
    frenchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Daily Verse' : 'Add Daily Verse'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(labelText: 'Reference (e.g. Yoannes 3:16)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: ewondoController,
                maxLines: 4,
                minLines: 2,
                decoration: const InputDecoration(labelText: 'Ewondo text'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: englishController,
                maxLines: 4,
                minLines: 2,
                decoration: const InputDecoration(labelText: 'English translation'),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: frenchController,
                maxLines: 4,
                minLines: 2,
                decoration: const InputDecoration(labelText: 'French translation'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (ewondoController.text.trim().isEmpty || referenceController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              DailyVerseFormResult(
                text: ewondoController.text.trim(),
                englishText: englishController.text.trim(),
                frenchText: frenchController.text.trim(),
                reference: referenceController.text.trim(),
              ),
            );
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

/// First step of "Add Daily Word": lets the admin pick an existing
/// Vocabulary entry rather than typing one from scratch. The picked word's
/// fields are only used to prefill the next (editable) form dialog.
class _VocabularyPickerDialog extends StatefulWidget {
  const _VocabularyPickerDialog({required this.languageId});

  final String languageId;

  @override
  State<_VocabularyPickerDialog> createState() => _VocabularyPickerDialogState();
}

class _VocabularyPickerDialogState extends State<_VocabularyPickerDialog> {
  final repository = KnowledgeRepository();
  final searchController = TextEditingController();
  List<KnowledgeWord> words = [];
  bool isLoading = true;
  String? error;

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
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await repository.getVocabulary(
        search: searchController.text.trim(),
        languageId: widget.languageId,
      );
      setState(() {
        words = result;
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        error = extractErrorMessage(e, fallback: 'Could not load vocabulary.');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a Vocabulary word'),
      content: SizedBox(
        width: 420,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => load(),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: isLoading
                  ? const ShimmerListLoader(itemCount: 5, itemHeight: 64)
                  : error != null
                      ? EmptyState(icon: Icons.error_outline, title: 'Something went wrong', message: error)
                      : words.isEmpty
                          ? const EmptyState(
                              icon: Icons.menu_book_outlined,
                              title: 'No vocabulary yet',
                              message: 'Add words in Vocabulary Management first.',
                            )
                          : ListView.separated(
                              itemCount: words.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final word = words[index];
                                return ListTile(
                                  title: Text(
                                    word.word,
                                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                    [word.englishMeaning, word.frenchMeaning]
                                        .where((m) => m != null && m.isNotEmpty)
                                        .join(' • '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => Navigator.pop(context, word),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }
}

/// First step of "Add Daily Verse": lets the admin pick a book/chapter, then
/// an existing verse from the Bible data, rather than typing one from
/// scratch. The picked verse's fields are only used to prefill the next
/// (editable) form dialog.
class _BibleVersePickerDialog extends StatefulWidget {
  const _BibleVersePickerDialog({required this.languageId});

  final String languageId;

  @override
  State<_BibleVersePickerDialog> createState() => _BibleVersePickerDialogState();
}

class _BibleVersePickerDialogState extends State<_BibleVersePickerDialog> {
  final repository = KnowledgeRepository();
  List<BibleChapterSummary> chapters = [];
  List<BibleVerseEntry> verses = [];
  BibleChapterSummary? selectedChapter;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  Future<void> loadChapters() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await repository.getBibleChapters(languageId: widget.languageId);
      setState(() {
        chapters = result;
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        error = extractErrorMessage(e, fallback: 'Could not load Bible chapters.');
        isLoading = false;
      });
    }
  }

  Future<void> selectChapter(BibleChapterSummary chapter) async {
    setState(() {
      selectedChapter = chapter;
      isLoading = true;
      error = null;
    });
    try {
      final result = await repository.getBibleVerses(
        book: chapter.book,
        chapter: chapter.chapter,
        languageId: widget.languageId,
      );
      setState(() {
        verses = result;
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        error = extractErrorMessage(e, fallback: 'Could not load verses.');
        isLoading = false;
      });
    }
  }

  void backToChapters() {
    setState(() {
      selectedChapter = null;
      verses = [];
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapter = selectedChapter;
    return AlertDialog(
      title: Text(chapter == null ? 'Pick a chapter' : '${chapter.book} ${chapter.chapter}'),
      content: SizedBox(
        width: 420,
        height: 480,
        child: isLoading
            ? const ShimmerListLoader(itemCount: 5, itemHeight: 64)
            : error != null
                ? EmptyState(icon: Icons.error_outline, title: 'Something went wrong', message: error)
                : chapter == null
                    ? (chapters.isEmpty
                        ? const EmptyState(
                            icon: Icons.menu_book_outlined,
                            title: 'No Bible content yet',
                            message: 'Add chapters in Bible Management first.',
                          )
                        : ListView.separated(
                            itemCount: chapters.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final c = chapters[index];
                              return ListTile(
                                title: Text(
                                  '${c.book} ${c.chapter}',
                                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text('${c.verseCount} verses'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => selectChapter(c),
                              );
                            },
                          ))
                    : (verses.isEmpty
                        ? const EmptyState(
                            icon: Icons.menu_book_outlined,
                            title: 'No verses yet',
                            message: 'This chapter has no verses.',
                          )
                        : ListView.separated(
                            itemCount: verses.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final verse = verses[index];
                              return ListTile(
                                title: Text(
                                  'Verse ${verse.verse}',
                                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  verse.text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => Navigator.pop(context, verse),
                              );
                            },
                          )),
      ),
      actions: [
        if (chapter != null) TextButton(onPressed: backToChapters, child: const Text('Back')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }
}
