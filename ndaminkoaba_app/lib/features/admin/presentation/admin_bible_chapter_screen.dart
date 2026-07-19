import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/knowledge_repository.dart';
import '../data/usfm_parser.dart';
import '../domain/knowledge_models.dart';

/// Matches a leading verse number on its own line, e.g. "12 In the
/// beginning..." or "12. In the beginning...". Pasted Bible text almost
/// always comes one verse per line in this shape, which is what lets the
/// Ewondo and English blobs be realigned by verse number instead of by
/// line position (robust to either side having a missing/extra verse).
final _versePattern = RegExp(r'^\s*(\d+)[\.\:]?\s+(.*)$');

class _VersePreview {
  const _VersePreview({
    required this.chapter,
    required this.verse,
    this.ewondoText,
    this.englishText,
    this.frenchText,
  });

  final int chapter;
  final int verse;
  final String? ewondoText;
  final String? englishText;
  final String? frenchText;
}

/// Lets an admin paste a full Bible chapter in Ewondo alongside its English
/// (ESV) translation, aligns the two verse-by-verse for review, then saves
/// the chapter as parallel-text knowledge for Nnanga to search — a third,
/// distinct way to grow the knowledge base beyond single words
/// (VocabFormDialog) or freeform text blocks (TextEntryFormDialog).
class AdminBibleChapterScreen extends StatefulWidget {
  const AdminBibleChapterScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminBibleChapterScreen> createState() => _AdminBibleChapterScreenState();
}

class _AdminBibleChapterScreenState extends State<AdminBibleChapterScreen> {
  final repository = KnowledgeRepository();
  final bookController = TextEditingController();
  final chapterController = TextEditingController();
  final versionController = TextEditingController(text: 'ESV');
  final ewondoController = TextEditingController();
  final englishController = TextEditingController();
  final frenchController = TextEditingController();

  bool isLoadingChapters = true;
  bool isSaving = false;
  bool isUsfmMode = false;
  List<BibleChapterSummary> savedChapters = [];
  List<_VersePreview> preview = [];

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  @override
  void dispose() {
    bookController.dispose();
    chapterController.dispose();
    versionController.dispose();
    ewondoController.dispose();
    englishController.dispose();
    frenchController.dispose();
    super.dispose();
  }

  Future<void> loadChapters() async {
    setState(() => isLoadingChapters = true);
    try {
      final result = await repository.getBibleChapters(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        savedChapters = result;
        isLoadingChapters = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingChapters = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _uploadUsfmFile(TextEditingController controller) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['usfm', 'sfm', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      _showMessage('Could not read that file.');
      return;
    }

    setState(() => controller.text = utf8.decode(bytes, allowMalformed: true));
    _showMessage('Loaded ${result.files.first.name}.');
  }

  List<({int verse, String text})> _parseVerses(String raw) {
    final result = <({int verse, String text})>[];
    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final match = _versePattern.firstMatch(line);
      if (match == null) continue;
      final verseNumber = int.tryParse(match.group(1)!);
      final text = match.group(2)!.trim();
      if (verseNumber != null && text.isNotEmpty) {
        result.add((verse: verseNumber, text: text));
      }
    }
    return result;
  }

  void buildPreview() {
    if (isUsfmMode) {
      _buildUsfmPreview();
    } else {
      _buildManualPreview();
    }
  }

  void _buildManualPreview() {
    final chapter = int.tryParse(chapterController.text.trim());
    if (chapter == null) {
      _showMessage('Enter a valid chapter number.');
      return;
    }

    final ewondoVerses = _parseVerses(ewondoController.text);
    final englishVerses = _parseVerses(englishController.text);
    final frenchVerses = _parseVerses(frenchController.text);

    if (ewondoVerses.isEmpty && englishVerses.isEmpty && frenchVerses.isEmpty) {
      _showMessage(
        'No numbered verses found. Paste one verse per line, each starting with its verse number.',
      );
      return;
    }

    final ewondoByVerse = {for (final v in ewondoVerses) v.verse: v.text};
    final englishByVerse = {for (final v in englishVerses) v.verse: v.text};
    final frenchByVerse = {for (final v in frenchVerses) v.verse: v.text};
    final verseNumbers = {...ewondoByVerse.keys, ...englishByVerse.keys, ...frenchByVerse.keys}.toList()
      ..sort();

    setState(() {
      preview = verseNumbers
          .map((n) => _VersePreview(
                chapter: chapter,
                verse: n,
                ewondoText: ewondoByVerse[n],
                englishText: englishByVerse[n],
                frenchText: frenchByVerse[n],
              ))
          .toList();
    });
  }

  void _buildUsfmPreview() {
    final ewondoResult = UsfmParser.parse(ewondoController.text);
    final englishResult = UsfmParser.parse(englishController.text);
    final frenchResult = UsfmParser.parse(frenchController.text);

    if (ewondoResult.verseCount == 0 && englishResult.verseCount == 0 && frenchResult.verseCount == 0) {
      _showMessage(
        'Could not find any \\v verse markers. Make sure you pasted valid USFM text '
        '(e.g. "\\c 1 \\v 1 In the beginning...").',
      );
      return;
    }

    final ewondoByChapter = {
      for (final c in ewondoResult.chapters) c.chapter: c.verses,
    };
    final englishByChapter = {
      for (final c in englishResult.chapters) c.chapter: c.verses,
    };
    final frenchByChapter = {
      for (final c in frenchResult.chapters) c.chapter: c.verses,
    };
    final chapterNumbers = {
      ...ewondoByChapter.keys,
      ...englishByChapter.keys,
      ...frenchByChapter.keys,
    }.toList()
      ..sort();

    final result = <_VersePreview>[];
    for (final chapterNum in chapterNumbers) {
      final ewondoVerses = ewondoByChapter[chapterNum] ?? {};
      final englishVerses = englishByChapter[chapterNum] ?? {};
      final frenchVerses = frenchByChapter[chapterNum] ?? {};
      final verseNumbers = {...ewondoVerses.keys, ...englishVerses.keys, ...frenchVerses.keys}.toList()
        ..sort();
      for (final verseNum in verseNumbers) {
        result.add(_VersePreview(
          chapter: chapterNum,
          verse: verseNum,
          ewondoText: ewondoVerses[verseNum],
          englishText: englishVerses[verseNum],
          frenchText: frenchVerses[verseNum],
        ));
      }
    }

    final detectedBook = ewondoResult.bookName ??
        englishResult.bookName ??
        frenchResult.bookName ??
        ewondoResult.bookCode ??
        englishResult.bookCode ??
        frenchResult.bookCode;

    setState(() {
      preview = result;
      if (detectedBook != null && detectedBook.isNotEmpty) {
        bookController.text = detectedBook;
      }
    });
  }

  Future<void> saveChapter() async {
    final book = bookController.text.trim();
    final version = versionController.text.trim().isEmpty ? 'ESV' : versionController.text.trim();

    if (book.isEmpty) {
      _showMessage('Enter a book name.');
      return;
    }

    final versesToSave = preview.where((v) => v.ewondoText != null && v.ewondoText!.isNotEmpty).toList();
    if (versesToSave.isEmpty) {
      _showMessage('No verses with Ewondo text to save — preview the comparison first.');
      return;
    }

    final chapterCount = versesToSave.map((v) => v.chapter).toSet().length;

    setState(() => isSaving = true);
    try {
      await repository.bulkUpsertBibleVerses(
        versesToSave
            .map((v) => {
                  'book': book,
                  'chapter': v.chapter,
                  'verse': v.verse,
                  'text': v.ewondoText,
                  if (v.englishText != null && v.englishText!.isNotEmpty) 'englishText': v.englishText,
                  if (v.frenchText != null && v.frenchText!.isNotEmpty) 'frenchText': v.frenchText,
                  'version': version,
                })
            .toList(),
        languageId: widget.languageId,
      );

      if (!mounted) return;
      setState(() {
        preview = [];
        ewondoController.clear();
        englishController.clear();
        frenchController.clear();
        if (isUsfmMode) chapterController.clear();
      });
      _showMessage(
        chapterCount > 1
            ? 'Saved ${versesToSave.length} verse(s) across $chapterCount chapters of $book.'
            : 'Saved ${versesToSave.length} verse(s) for $book.',
      );
      loadChapters();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not save chapter.'));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> deleteChapter(BibleChapterSummary summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: Text(
          'Delete all ${summary.verseCount} verse(s) of ${summary.book} ${summary.chapter} (${summary.version})?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
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
      await repository.deleteBibleChapter(
        book: summary.book,
        chapter: summary.chapter,
        version: summary.version,
        languageId: widget.languageId,
      );
      loadChapters();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete chapter.'));
    }
  }

  Widget _field(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _pasteBox(
    String label,
    String helper,
    String hint,
    TextEditingController controller, {
    VoidCallback? onUpload,
  }) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTypography.title)),
              if (onUpload != null)
                TextButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload File'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(helper, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            maxLines: 14,
            minLines: 6,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              hintText: hint,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Preview verses grouped by chapter, in chapter order — a single group
  /// for manual mode, potentially dozens for a whole USFM book.
  List<MapEntry<int, List<_VersePreview>>> get _previewChapters {
    final grouped = <int, List<_VersePreview>>{};
    for (final item in preview) {
      grouped.putIfAbsent(item.chapter, () => []).add(item);
    }
    final entries = grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  Widget _chapterPreviewSection(MapEntry<int, List<_VersePreview>> entry) {
    final chapter = entry.key;
    final verses = entry.value;
    final rows = verses.map(_verseRow).toList();

    if (_previewChapters.length == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text('Chapter $chapter', style: AppTypography.title.copyWith(fontSize: 15)),
        subtitle: Text('${verses.length} verses', style: AppTypography.caption),
        children: rows,
      ),
    );
  }

  bool get _hasFrenchData => preview.any((v) => v.frenchText != null && v.frenchText!.isNotEmpty);

  Widget _verseRow(_VersePreview item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.verse}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.ewondoText != null)
                  Text(item.ewondoText!, style: AppTypography.body)
                else
                  Text(
                    'Missing Ewondo text',
                    style: AppTypography.body.copyWith(
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                if (item.englishText != null)
                  Text(item.englishText!, style: AppTypography.caption)
                else
                  Text(
                    'Missing English text',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (_hasFrenchData) ...[
                  const SizedBox(height: AppSpacing.xs),
                  if (item.frenchText != null)
                    Text(item.frenchText!, style: AppTypography.caption)
                  else
                    Text(
                      'Missing French text',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warning,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(
        title: 'Bible Management',
        colors: [Color(0xFF0D7A4C), Color(0xFF6B4CE0)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUsfmMode
                    ? 'Upload (or paste) an entire book\'s USFM in Ewondo alongside its '
                        'English (ESV) USFM. Chapters and verses are detected automatically '
                        'from the \\c and \\v markers and matched verse by verse.'
                    : 'Paste a full chapter in Ewondo (New Testament) alongside its English '
                        '(ESV) translation. Each is matched verse by verse so Nnanga learns '
                        'accurate, side-by-side translations.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('Single Chapter'),
                    selected: !isUsfmMode,
                    onSelected: (_) => setState(() {
                      isUsfmMode = false;
                      preview = [];
                    }),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: !isUsfmMode ? Colors.white : AppColors.textPrimary),
                  ),
                  ChoiceChip(
                    label: const Text('USFM (Whole Book)'),
                    selected: isUsfmMode,
                    onSelected: (_) => setState(() {
                      isUsfmMode = true;
                      preview = [];
                    }),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isUsfmMode ? Colors.white : AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isUsfmMode ? 'Book Details' : 'Chapter Details', style: AppTypography.title),
                    if (isUsfmMode) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Auto-filled from the USFM \\h/\\mt1 title once previewed — edit if needed.',
                        style: AppTypography.caption,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _field('Book', bookController),
                        const SizedBox(width: AppSpacing.md),
                        if (!isUsfmMode) ...[
                          _field('Chapter', chapterController, keyboardType: TextInputType.number),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        _field('Version', versionController),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _pasteBox(
                isUsfmMode ? 'Ewondo USFM (entire book)' : 'Ewondo Chapter Text',
                isUsfmMode
                    ? 'Upload a .usfm/.sfm/.txt file, or paste the text directly.'
                    : 'One verse per line, each starting with its verse number.',
                isUsfmMode
                    ? '\\id JHN\n\\h John\n\\c 1\n\\v 1 Kiki avele, Nkobo a nga bo...\n\\v 2 ...'
                    : '1 In the beginning was the Word...\n2 He was in the beginning with God...',
                ewondoController,
                onUpload: isUsfmMode ? () => _uploadUsfmFile(ewondoController) : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              _pasteBox(
                isUsfmMode ? 'English USFM (entire book, ESV)' : 'English Chapter Text (ESV)',
                isUsfmMode
                    ? 'Upload a .usfm/.sfm/.txt file, or paste the text directly.'
                    : 'One verse per line, each starting with its verse number.',
                isUsfmMode
                    ? '\\id JHN\n\\h John\n\\c 1\n\\v 1 In the beginning was the Word...\n\\v 2 ...'
                    : '1 In the beginning was the Word...\n2 He was in the beginning with God...',
                englishController,
                onUpload: isUsfmMode ? () => _uploadUsfmFile(englishController) : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              _pasteBox(
                isUsfmMode ? 'French USFM (entire book, optional)' : 'French Chapter Text (optional)',
                isUsfmMode
                    ? 'Upload a .usfm/.sfm/.txt file, or paste the text directly.'
                    : 'One verse per line, each starting with its verse number.',
                isUsfmMode
                    ? '\\id JHN\n\\h Jean\n\\c 1\n\\v 1 Au commencement était la Parole...\n\\v 2 ...'
                    : '1 Au commencement était la Parole...\n2 Elle était au commencement avec Dieu...',
                frenchController,
                onUpload: isUsfmMode ? () => _uploadUsfmFile(frenchController) : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: buildPreview,
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Preview Verse-by-Verse Comparison'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                  ),
                ),
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verse-by-Verse Comparison', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${preview.length} verses across ${_previewChapters.length} '
                        '${_previewChapters.length == 1 ? 'chapter' : 'chapters'}',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ..._previewChapters.map(_chapterPreviewSection),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: isUsfmMode ? 'Save Book' : 'Save Chapter',
                  icon: Icons.save_outlined,
                  isLoading: isSaving,
                  onPressed: saveChapter,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              Text('Saved Chapters', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              isLoadingChapters
                  ? const ShimmerListLoader(itemCount: 2, itemHeight: 72)
                  : savedChapters.isEmpty
                      ? EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'No chapters yet',
                          message: 'Paste and save a chapter above to see it here.',
                        )
                      : Column(
                          children: savedChapters
                              .map(
                                (summary) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: PremiumCard(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6B4CE0).withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.menu_book_outlined,
                                            color: Color(0xFF6B4CE0),
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${summary.book} ${summary.chapter}',
                                                style: AppTypography.title,
                                              ),
                                              Text(
                                                '${summary.version} • ${summary.verseCount} verses',
                                                style: AppTypography.caption,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                          tooltip: 'Delete chapter',
                                          onPressed: () => deleteChapter(summary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
