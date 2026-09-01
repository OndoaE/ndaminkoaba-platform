import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
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

/// One file picked (or pasted) for a single language slot in USFM batch
/// mode. Unlike the single-string paste boxes this app started with, a
/// slot can now hold many of these at once -- one file per book.
class _UsfmFileUpload {
  const _UsfmFileUpload({required this.fileName, required this.rawText});

  final String fileName;
  final String rawText;
}

/// Accumulates the Ewondo/English/French USFM parse results that share a
/// detected book identity, before they're flattened into a [_BookDraft].
/// Kept as a small mutable holder (not a record) because it's built up
/// incrementally across three separate passes (one per language).
class _BookAccumulator {
  _BookAccumulator(this.displayName);

  String displayName;
  UsfmParseResult? ewondo;
  UsfmParseResult? english;
  UsfmParseResult? french;
}

/// One book's worth of reviewable, editable, individually-savable content
/// in USFM batch mode -- the whole point of this screen supporting more
/// than one book per upload. [bookController] starts pre-filled from
/// whatever the source files' own USFM headers declared, but stays fully
/// editable in case detection picked the wrong name or none at all.
class _BookDraft {
  _BookDraft({required String initialBook, required this.verses})
      : bookController = TextEditingController(text: initialBook);

  final TextEditingController bookController;
  final List<_VersePreview> verses;
  bool include = true;

  int get chapterCount => verses.map((v) => v.chapter).toSet().length;

  void dispose() => bookController.dispose();
}

/// Lets an admin paste a full Bible chapter in Ewondo alongside its English
/// (ESV) translation, aligns the two verse-by-verse for review, then saves
/// the chapter as parallel-text knowledge for Nnanga to search -- a third,
/// distinct way to grow the knowledge base beyond single words
/// (VocabFormDialog) or freeform text blocks (TextEntryFormDialog).
///
/// USFM mode is a separate, batch-capable path: an admin can select many
/// files at once per language (e.g. every book from Acts to Revelation),
/// each file is matched across the three language slots by its own USFM
/// book identity, and every resulting book is reviewed and saved as its
/// own independent [_BookDraft] -- one succeeding or failing does not
/// affect the others.
class AdminBibleChapterScreen extends StatefulWidget {
  const AdminBibleChapterScreen({
    super.key,
    required this.languageId,
    this.languageName,
  });

  final String languageId;
  final String? languageName;

  @override
  State<AdminBibleChapterScreen> createState() =>
      _AdminBibleChapterScreenState();
}

class _AdminBibleChapterScreenState extends State<AdminBibleChapterScreen> {
  final repository = KnowledgeRepository();
  final bookController = TextEditingController();
  final chapterController = TextEditingController();
  final versionController = TextEditingController();
  final ewondoController = TextEditingController();
  final englishController = TextEditingController();
  final frenchController = TextEditingController();

  bool isLoadingChapters = true;
  bool isSaving = false;
  bool isSavingAll = false;
  bool isUsfmMode = false;
  bool _defaultVersionSet = false;
  List<BibleChapterSummary> savedChapters = [];

  // Manual (single-chapter) mode only.
  List<_VersePreview> preview = [];

  // USFM batch mode only.
  List<_UsfmFileUpload> ewondoFiles = [];
  List<_UsfmFileUpload> englishFiles = [];
  List<_UsfmFileUpload> frenchFiles = [];
  List<_BookDraft> bookDrafts = [];

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultVersionSet) {
      _defaultVersionSet = true;
      versionController.text = AppLocalizations.of(context).adminBibleChapterDefaultVersion;
    }
  }

  @override
  void dispose() {
    bookController.dispose();
    chapterController.dispose();
    versionController.dispose();
    ewondoController.dispose();
    englishController.dispose();
    frenchController.dispose();
    for (final draft in bookDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> loadChapters() async {
    setState(() => isLoadingChapters = true);
    try {
      final result = await repository.getBibleChapters(
        languageId: widget.languageId,
      );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearBookDrafts() {
    for (final draft in bookDrafts) {
      draft.dispose();
    }
    bookDrafts = [];
  }

  /// Picks one or many USFM/SFM/txt files for a single language slot.
  /// Replaces whatever was previously picked for that slot -- consistent
  /// with the rest of this screen's "a fresh pick replaces stale state"
  /// rule, so a previous batch's files can never silently linger into a
  /// new one.
  Future<void> _pickUsfmFiles(void Function(List<_UsfmFileUpload>) onPicked) async {
    final l10n = AppLocalizations.of(context);
    // pickFiles already defaults to allowMultiple: true -- that's the
    // whole point of this screen supporting more than one book per
    // upload, so it's picked once here and never overridden to false.
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['usfm', 'sfm', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = <_UsfmFileUpload>[];
    var unreadable = 0;
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) {
        unreadable++;
        continue;
      }
      picked.add(
        _UsfmFileUpload(fileName: file.name, rawText: utf8.decode(bytes, allowMalformed: true)),
      );
    }

    if (picked.isEmpty) {
      _showMessage(l10n.adminBibleChapterFileReadError);
      return;
    }

    setState(() {
      onPicked(picked);
      // A fresh pick means fresh books -- the previous preview no longer
      // reflects what's about to be built, and could otherwise be saved
      // by mistake if the admin doesn't re-run Preview.
      _clearBookDrafts();
    });
    _showMessage(
      unreadable > 0
          ? l10n.adminBibleChapterFilesLoadedWithErrors(picked.length, unreadable)
          : l10n.adminBibleChapterFilesLoaded(picked.length),
    );
  }

  void _removeUsfmFile(List<_UsfmFileUpload> files, void Function(List<_UsfmFileUpload>) onChanged, int index) {
    final updated = List<_UsfmFileUpload>.from(files)..removeAt(index);
    setState(() {
      onChanged(updated);
      _clearBookDrafts();
    });
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
      _buildUsfmBookDrafts();
    } else {
      _buildManualPreview();
    }
  }

  void _buildManualPreview() {
    final l10n = AppLocalizations.of(context);
    final chapter = int.tryParse(chapterController.text.trim());
    if (chapter == null) {
      _showMessage(l10n.adminBibleChapterInvalidChapterError);
      return;
    }

    final ewondoVerses = _parseVerses(ewondoController.text);
    final englishVerses = _parseVerses(englishController.text);
    final frenchVerses = _parseVerses(frenchController.text);

    if (ewondoVerses.isEmpty && englishVerses.isEmpty && frenchVerses.isEmpty) {
      _showMessage(
        l10n.adminBibleChapterNoVersesFoundError,
      );
      return;
    }

    final ewondoByVerse = {for (final v in ewondoVerses) v.verse: v.text};
    final englishByVerse = {for (final v in englishVerses) v.verse: v.text};
    final frenchByVerse = {for (final v in frenchVerses) v.verse: v.text};
    final verseNumbers = {
      ...ewondoByVerse.keys,
      ...englishByVerse.keys,
      ...frenchByVerse.keys,
    }.toList()..sort();

    setState(() {
      preview = verseNumbers
          .map(
            (n) => _VersePreview(
              chapter: chapter,
              verse: n,
              ewondoText: ewondoByVerse[n],
              englishText: englishByVerse[n],
              frenchText: frenchByVerse[n],
            ),
          )
          .toList();
    });
  }

  /// Builds this batch's book drafts: parses every picked file (plus any
  /// directly-pasted text, treated as one more unit) per language slot,
  /// groups units across all three slots by their detected USFM book
  /// identity (code, then name, then filename as a last resort so a file
  /// with no recognizable header still becomes its own reviewable draft
  /// instead of silently vanishing), and turns each group into a
  /// [_BookDraft] with its own editable book name and its own chapter/
  /// verse content -- ready to be reviewed and saved independently.
  void _buildUsfmBookDrafts() {
    final l10n = AppLocalizations.of(context);

    final ewondoUnits = [
      ...ewondoFiles,
      if (ewondoController.text.trim().isNotEmpty)
        _UsfmFileUpload(
          fileName: l10n.adminBibleChapterPastedTextLabel,
          rawText: ewondoController.text,
        ),
    ];
    final englishUnits = [
      ...englishFiles,
      if (englishController.text.trim().isNotEmpty)
        _UsfmFileUpload(
          fileName: l10n.adminBibleChapterPastedTextLabel,
          rawText: englishController.text,
        ),
    ];
    final frenchUnits = [
      ...frenchFiles,
      if (frenchController.text.trim().isNotEmpty)
        _UsfmFileUpload(
          fileName: l10n.adminBibleChapterPastedTextLabel,
          rawText: frenchController.text,
        ),
    ];

    if (ewondoUnits.isEmpty && englishUnits.isEmpty && frenchUnits.isEmpty) {
      _showMessage(l10n.adminBibleChapterNoUsfmMarkersError);
      return;
    }

    final byKey = <String, _BookAccumulator>{};

    void accumulate(
      List<_UsfmFileUpload> units,
      void Function(_BookAccumulator acc, UsfmParseResult parsed) assign,
    ) {
      for (final unit in units) {
        final parsed = UsfmParser.parse(unit.rawText);
        if (parsed.verseCount == 0) continue;
        final key = (parsed.bookCode ?? parsed.bookName ?? unit.fileName).trim().toUpperCase();
        final displayName = parsed.bookName ?? parsed.bookCode ?? unit.fileName;
        final acc = byKey.putIfAbsent(key, () => _BookAccumulator(displayName));
        assign(acc, parsed);
      }
    }

    accumulate(ewondoUnits, (acc, parsed) => acc.ewondo = parsed);
    accumulate(englishUnits, (acc, parsed) => acc.english = parsed);
    accumulate(frenchUnits, (acc, parsed) => acc.french = parsed);

    if (byKey.isEmpty) {
      _showMessage(l10n.adminBibleChapterNoUsfmMarkersError);
      return;
    }

    final drafts = <_BookDraft>[];
    for (final acc in byKey.values) {
      final ewondoByChapter = {
        for (final c in acc.ewondo?.chapters ?? const <UsfmChapter>[]) c.chapter: c.verses,
      };
      final englishByChapter = {
        for (final c in acc.english?.chapters ?? const <UsfmChapter>[]) c.chapter: c.verses,
      };
      final frenchByChapter = {
        for (final c in acc.french?.chapters ?? const <UsfmChapter>[]) c.chapter: c.verses,
      };
      final chapterNumbers = {
        ...ewondoByChapter.keys,
        ...englishByChapter.keys,
        ...frenchByChapter.keys,
      }.toList()..sort();

      final verses = <_VersePreview>[];
      for (final chapterNum in chapterNumbers) {
        final ewondoVerses = ewondoByChapter[chapterNum] ?? {};
        final englishVerses = englishByChapter[chapterNum] ?? {};
        final frenchVerses = frenchByChapter[chapterNum] ?? {};
        final verseNumbers = {
          ...ewondoVerses.keys,
          ...englishVerses.keys,
          ...frenchVerses.keys,
        }.toList()..sort();
        for (final verseNum in verseNumbers) {
          verses.add(
            _VersePreview(
              chapter: chapterNum,
              verse: verseNum,
              ewondoText: ewondoVerses[verseNum],
              englishText: englishVerses[verseNum],
              frenchText: frenchVerses[verseNum],
            ),
          );
        }
      }
      drafts.add(_BookDraft(initialBook: acc.displayName, verses: verses));
    }
    drafts.sort(
      (a, b) => a.bookController.text.toLowerCase().compareTo(b.bookController.text.toLowerCase()),
    );

    setState(() {
      _clearBookDrafts();
      bookDrafts = drafts;
    });
  }

  Future<void> saveChapter() async {
    final l10n = AppLocalizations.of(context);
    final book = bookController.text.trim();
    final version = versionController.text.trim().isEmpty
        ? l10n.adminBibleChapterDefaultVersion
        : versionController.text.trim();

    if (book.isEmpty) {
      _showMessage(l10n.adminBibleChapterEnterBookNameError);
      return;
    }

    final versesToSave = preview
        .where((v) => v.ewondoText != null && v.ewondoText!.isNotEmpty)
        .toList();
    if (versesToSave.isEmpty) {
      _showMessage(
        l10n.adminBibleChapterNoEwondoVersesError,
      );
      return;
    }

    final chapterCount = versesToSave.map((v) => v.chapter).toSet().length;

    // Safety net: if this book+version already has any of these chapters
    // saved, saving again would silently overwrite them (same book/
    // chapter/verse/version/language upsert key on the backend) --
    // surface that plainly instead of letting it happen invisibly.
    final chaptersInPreview = versesToSave.map((v) => v.chapter).toSet();
    final collidingChapters = savedChapters
        .where(
          (s) =>
              s.book == book &&
              s.version == version &&
              chaptersInPreview.contains(s.chapter),
        )
        .map((s) => s.chapter)
        .toSet();
    if (collidingChapters.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.adminBibleChapterOverwriteTitle),
          content: Text(
            l10n.adminBibleChapterOverwriteConfirm(collidingChapters.length, book),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.adminBibleChapterCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.adminBibleChapterOverwriteButton),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => isSaving = true);
    try {
      await repository.bulkUpsertBibleVerses(
        versesToSave
            .map(
              (v) => {
                'book': book,
                'chapter': v.chapter,
                'verse': v.verse,
                'text': v.ewondoText,
                if (v.englishText != null && v.englishText!.isNotEmpty)
                  'englishText': v.englishText,
                if (v.frenchText != null && v.frenchText!.isNotEmpty)
                  'frenchText': v.frenchText,
                'version': version,
              },
            )
            .toList(),
        languageId: widget.languageId,
      );

      if (!mounted) return;
      setState(() {
        preview = [];
        ewondoController.clear();
        englishController.clear();
        frenchController.clear();
      });
      _showMessage(
        chapterCount > 1
            ? l10n.adminBibleChapterSavedMultiChapters(versesToSave.length, chapterCount, book)
            : l10n.adminBibleChapterSavedSingleChapter(versesToSave.length, book),
      );
      loadChapters();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBibleChapterSaveError));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  /// Saves every included book draft independently -- one book's payload
  /// failing (a validation error, a network blip) does not stop the rest
  /// of the batch, matching how the admin's paste-import features (quiz,
  /// vocabulary) already report partial success rather than all-or-
  /// nothing.
  Future<void> saveAllBooks() async {
    final l10n = AppLocalizations.of(context);
    final version = versionController.text.trim().isEmpty
        ? l10n.adminBibleChapterDefaultVersion
        : versionController.text.trim();

    final toSave = bookDrafts.where((d) => d.include).toList();
    if (toSave.isEmpty) return;

    for (final draft in toSave) {
      if (draft.bookController.text.trim().isEmpty) {
        _showMessage(l10n.adminBibleChapterEnterBookNameError);
        return;
      }
    }

    final versesByDraft = {
      for (final draft in toSave)
        draft: draft.verses.where((v) => v.ewondoText != null && v.ewondoText!.isNotEmpty).toList(),
    };
    if (versesByDraft.values.every((v) => v.isEmpty)) {
      _showMessage(l10n.adminBibleChapterNoEwondoVersesError);
      return;
    }

    // Same overwrite safety net as the single-book save, aggregated
    // across the whole batch into one upfront confirmation rather than
    // one dialog per book.
    var booksWithCollisions = 0;
    for (final draft in toSave) {
      final book = draft.bookController.text.trim();
      final chaptersInDraft = versesByDraft[draft]!.map((v) => v.chapter).toSet();
      final hasCollision = savedChapters.any(
        (s) => s.book == book && s.version == version && chaptersInDraft.contains(s.chapter),
      );
      if (hasCollision) booksWithCollisions++;
    }
    if (booksWithCollisions > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.adminBibleChapterOverwriteTitle),
          content: Text(
            l10n.adminBibleChapterOverwriteConfirmMulti(booksWithCollisions, toSave.length),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.adminBibleChapterCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.adminBibleChapterOverwriteButton),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => isSavingAll = true);
    var succeeded = 0;
    var failed = 0;
    String? firstError;
    for (final draft in toSave) {
      final verses = versesByDraft[draft]!;
      if (verses.isEmpty) continue;
      final book = draft.bookController.text.trim();
      try {
        await repository.bulkUpsertBibleVerses(
          verses
              .map(
                (v) => {
                  'book': book,
                  'chapter': v.chapter,
                  'verse': v.verse,
                  'text': v.ewondoText,
                  if (v.englishText != null && v.englishText!.isNotEmpty)
                    'englishText': v.englishText,
                  if (v.frenchText != null && v.frenchText!.isNotEmpty)
                    'frenchText': v.frenchText,
                  'version': version,
                },
              )
              .toList(),
          languageId: widget.languageId,
        );
        succeeded++;
      } on DioException catch (e) {
        failed++;
        firstError ??= extractErrorMessage(e, fallback: l10n.adminBibleChapterSaveError);
      } catch (e) {
        failed++;
        firstError ??= e.toString();
      }
    }

    if (!mounted) return;
    setState(() {
      _clearBookDrafts();
      ewondoFiles = [];
      englishFiles = [];
      frenchFiles = [];
      ewondoController.clear();
      englishController.clear();
      frenchController.clear();
      isSavingAll = false;
    });
    _showMessage(
      failed == 0
          ? l10n.adminBibleChapterSavedBooks(succeeded)
          : l10n.adminBibleChapterSavedBooksWithFailures(
              succeeded,
              failed,
              firstError != null ? ' — $firstError' : '',
            ),
    );
    loadChapters();
  }

  Future<void> deleteChapter(BibleChapterSummary summary) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminBibleChapterDeleteChapterTitle),
        content: Text(
          l10n.adminBibleChapterDeleteChapterConfirm(
            summary.verseCount,
            summary.book,
            summary.chapter,
            summary.version,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.adminBibleChapterCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.adminBibleChapterDelete),
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
      _showMessage(
        extractErrorMessage(e, fallback: l10n.adminBibleChapterDeleteError),
      );
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
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
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
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
    List<_UsfmFileUpload>? files,
    void Function(int index)? onRemoveFile,
  }) {
    final l10n = AppLocalizations.of(context);
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
                  label: Text(l10n.adminBibleChapterUploadFileButton),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(helper, style: AppTypography.caption),
          if (files != null && files.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var i = 0; i < files.length; i++)
                  Chip(
                    label: Text(files[i].fileName, overflow: TextOverflow.ellipsis),
                    visualDensity: VisualDensity.compact,
                    onDeleted: onRemoveFile == null ? null : () => onRemoveFile(i),
                  ),
              ],
            ),
          ],
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

  /// Groups a book's verses by chapter, in chapter order — a single group
  /// for a manual-mode chapter, potentially dozens for a whole USFM book.
  List<MapEntry<int, List<_VersePreview>>> _chaptersOf(List<_VersePreview> verses) {
    final grouped = <int, List<_VersePreview>>{};
    for (final item in verses) {
      grouped.putIfAbsent(item.chapter, () => []).add(item);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  Widget _chapterPreviewSection(MapEntry<int, List<_VersePreview>> entry, {required bool singleChapter}) {
    final l10n = AppLocalizations.of(context);
    final chapter = entry.key;
    final verses = entry.value;
    final hasFrenchData = _hasFrenchDataIn(verses);
    final rows = verses.map((v) => _verseRow(v, hasFrenchData: hasFrenchData)).toList();

    if (singleChapter) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          l10n.adminBibleChapterChapterHeading(chapter),
          style: AppTypography.title.copyWith(fontSize: 15),
        ),
        subtitle: Text(l10n.adminBibleChapterVerseCount(verses.length), style: AppTypography.caption),
        children: rows,
      ),
    );
  }

  bool _hasFrenchDataIn(List<_VersePreview> verses) =>
      verses.any((v) => v.frenchText != null && v.frenchText!.isNotEmpty);

  Widget _verseRow(_VersePreview item, {required bool hasFrenchData}) {
    final l10n = AppLocalizations.of(context);
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
                    l10n.adminBibleChapterMissingEwondoText,
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
                    l10n.adminBibleChapterMissingEnglishText,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warning,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (hasFrenchData) ...[
                  const SizedBox(height: AppSpacing.xs),
                  if (item.frenchText != null)
                    Text(item.frenchText!, style: AppTypography.caption)
                  else
                    Text(
                      l10n.adminBibleChapterMissingFrenchText,
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

  Widget _bookDraftCard(_BookDraft draft) {
    final l10n = AppLocalizations.of(context);
    final chapters = _chaptersOf(draft.verses);
    final singleChapter = chapters.length == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: draft.include,
                  onChanged: (v) => setState(() => draft.include = v ?? true),
                ),
                Expanded(
                  child: TextField(
                    controller: draft.bookController,
                    style: AppTypography.title,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                l10n.adminBibleChapterVersesAcrossChapters(draft.verses.length, draft.chapterCount),
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: chapters
                    .map((entry) => _chapterPreviewSection(entry, singleChapter: singleChapter))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.languageName ?? l10n.adminBibleChapterDefaultLanguageName;
    final manualChapters = _chaptersOf(preview);
    return AdminShell(
      activeNavKey: 'bible',
      languageId: widget.languageId,
      languageName: title,
      title: l10n.adminBibleChapterTitle,
      subtitle: l10n.adminBibleChapterSubtitle(title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isUsfmMode
                ? l10n.adminBibleChapterUsfmModeInstructions
                : l10n.adminBibleChapterManualModeInstructions,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: Text(l10n.adminBibleChapterSingleChapterOption),
                selected: !isUsfmMode,
                onSelected: (_) => setState(() {
                  isUsfmMode = false;
                  preview = [];
                  _clearBookDrafts();
                }),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: !isUsfmMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              ChoiceChip(
                label: Text(l10n.adminBibleChapterUsfmWholeBookOption),
                selected: isUsfmMode,
                onSelected: (_) => setState(() {
                  isUsfmMode = true;
                  preview = [];
                  _clearBookDrafts();
                }),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isUsfmMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUsfmMode ? l10n.adminBibleChapterBookDetailsTitle : l10n.adminBibleChapterChapterDetailsTitle,
                  style: AppTypography.title,
                ),
                if (isUsfmMode) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.adminBibleChapterAutoFilledHint,
                    style: AppTypography.caption,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // In USFM batch mode each book gets its own editable
                    // name inline in its review card below, so the single
                    // shared Book field here only applies to manual mode.
                    if (!isUsfmMode) ...[
                      _field(l10n.adminBibleChapterBookLabel, bookController),
                      const SizedBox(width: AppSpacing.md),
                      _field(
                        l10n.adminBibleChapterChapterLabel,
                        chapterController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    _field(l10n.adminBibleChapterVersionLabel, versionController),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _pasteBox(
            isUsfmMode ? l10n.adminBibleChapterEwondoUsfmLabel : l10n.adminBibleChapterEwondoChapterLabel,
            isUsfmMode
                ? l10n.adminBibleChapterUploadOrPasteHelper
                : l10n.adminBibleChapterOneVersePerLineHelper,
            isUsfmMode
                ? l10n.adminBibleChapterEwondoUsfmHintExample
                : l10n.adminBibleChapterManualHintExample,
            ewondoController,
            onUpload: isUsfmMode
                ? () => _pickUsfmFiles((f) => ewondoFiles = f)
                : null,
            files: isUsfmMode ? ewondoFiles : null,
            onRemoveFile: isUsfmMode
                ? (i) => _removeUsfmFile(ewondoFiles, (f) => ewondoFiles = f, i)
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _pasteBox(
            isUsfmMode
                ? l10n.adminBibleChapterEnglishUsfmLabel
                : l10n.adminBibleChapterEnglishChapterLabel,
            isUsfmMode
                ? l10n.adminBibleChapterUploadOrPasteHelper
                : l10n.adminBibleChapterOneVersePerLineHelper,
            isUsfmMode
                ? l10n.adminBibleChapterEnglishUsfmHintExample
                : l10n.adminBibleChapterManualHintExample,
            englishController,
            onUpload: isUsfmMode
                ? () => _pickUsfmFiles((f) => englishFiles = f)
                : null,
            files: isUsfmMode ? englishFiles : null,
            onRemoveFile: isUsfmMode
                ? (i) => _removeUsfmFile(englishFiles, (f) => englishFiles = f, i)
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _pasteBox(
            isUsfmMode
                ? l10n.adminBibleChapterFrenchUsfmLabel
                : l10n.adminBibleChapterFrenchChapterLabel,
            isUsfmMode
                ? l10n.adminBibleChapterUploadOrPasteHelper
                : l10n.adminBibleChapterOneVersePerLineHelper,
            isUsfmMode
                ? l10n.adminBibleChapterFrenchUsfmHintExample
                : l10n.adminBibleChapterFrenchManualHintExample,
            frenchController,
            onUpload: isUsfmMode
                ? () => _pickUsfmFiles((f) => frenchFiles = f)
                : null,
            files: isUsfmMode ? frenchFiles : null,
            onRemoveFile: isUsfmMode
                ? (i) => _removeUsfmFile(frenchFiles, (f) => frenchFiles = f, i)
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: buildPreview,
              icon: const Icon(Icons.compare_arrows),
              label: Text(l10n.adminBibleChapterPreviewButton),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
              ),
            ),
          ),
          if (!isUsfmMode && preview.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.adminBibleChapterComparisonTitle, style: AppTypography.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.adminBibleChapterVersesAcrossChapters(preview.length, manualChapters.length),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...manualChapters.map(
                    (entry) => _chapterPreviewSection(entry, singleChapter: manualChapters.length == 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.adminBibleChapterSaveChapterButton,
              icon: Icons.save_outlined,
              isLoading: isSaving,
              onPressed: saveChapter,
            ),
          ],
          if (isUsfmMode && bookDrafts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.adminBibleChapterBooksDetectedSummary(bookDrafts.length),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            ...bookDrafts.map(_bookDraftCard),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: l10n.adminBibleChapterSaveAllBooksButton(
                bookDrafts.where((d) => d.include).length,
              ),
              icon: Icons.save_outlined,
              isLoading: isSavingAll,
              onPressed: saveAllBooks,
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.adminBibleChapterSavedChaptersHeading, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          isLoadingChapters
              ? const ShimmerListLoader(itemCount: 2, itemHeight: 72)
              : savedChapters.isEmpty
              ? EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: l10n.adminBibleChapterEmptyTitle,
                  message: l10n.adminBibleChapterEmptyMessage,
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
                                    color: const Color(
                                      0xFF6B4CE0,
                                    ).withValues(alpha: 0.12),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  tooltip: l10n.adminBibleChapterDeleteChapterTooltip,
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
    );
  }
}
