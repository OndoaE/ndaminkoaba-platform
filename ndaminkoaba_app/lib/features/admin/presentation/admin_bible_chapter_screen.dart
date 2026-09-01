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

/// Lets an admin paste a full Bible chapter in Ewondo alongside its English
/// (ESV) translation, aligns the two verse-by-verse for review, then saves
/// the chapter as parallel-text knowledge for Nnanga to search — a third,
/// distinct way to grow the knowledge base beyond single words
/// (VocabFormDialog) or freeform text blocks (TextEntryFormDialog).
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
  bool isUsfmMode = false;
  bool _defaultVersionSet = false;
  List<BibleChapterSummary> savedChapters = [];
  List<_VersePreview> preview = [];

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

  Future<void> _uploadUsfmFile(TextEditingController controller) async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['usfm', 'sfm', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      _showMessage(l10n.adminBibleChapterFileReadError);
      return;
    }

    setState(() {
      controller.text = utf8.decode(bytes, allowMalformed: true);
      // A fresh file means a fresh book -- never let a book name detected
      // (or typed) for a *previous* upload silently carry over. Without
      // this, uploading e.g. Matthew after John, when Matthew's USFM
      // header isn't recognized, would leave "John" in the field and
      // Preview/Save would upsert Matthew's verses into John's rows
      // (same book+chapter+verse key), silently corrupting John's text
      // instead of adding Matthew as its own book. Preview re-fills this
      // from the new file's own header if one is found; if not, it now
      // stays empty (visible, obvious) rather than wrong-but-plausible.
      bookController.clear();
      preview = [];
    });
    _showMessage(l10n.adminBibleChapterFileLoaded(result.files.first.name));
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

  void _buildUsfmPreview() {
    final l10n = AppLocalizations.of(context);
    final ewondoResult = UsfmParser.parse(ewondoController.text);
    final englishResult = UsfmParser.parse(englishController.text);
    final frenchResult = UsfmParser.parse(frenchController.text);

    if (ewondoResult.verseCount == 0 &&
        englishResult.verseCount == 0 &&
        frenchResult.verseCount == 0) {
      _showMessage(
        l10n.adminBibleChapterNoUsfmMarkersError,
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
    }.toList()..sort();

    final result = <_VersePreview>[];
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
        result.add(
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

    final detectedBook =
        ewondoResult.bookName ??
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

    // Safety net for the exact failure mode that made "only one USFM
    // ends up saved" possible: if this book+version already has any of
    // these chapters saved, saving again would silently overwrite them
    // (same book/chapter/verse/version/language upsert key on the
    // backend) -- surface that plainly instead of letting it happen
    // invisibly, whether it's a genuine intentional re-upload or a
    // book name that wasn't changed from the previous book.
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
        if (isUsfmMode) chapterController.clear();
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
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  Widget _chapterPreviewSection(MapEntry<int, List<_VersePreview>> entry) {
    final l10n = AppLocalizations.of(context);
    final chapter = entry.key;
    final verses = entry.value;
    final rows = verses.map(_verseRow).toList();

    if (_previewChapters.length == 1) {
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

  bool get _hasFrenchData =>
      preview.any((v) => v.frenchText != null && v.frenchText!.isNotEmpty);

  Widget _verseRow(_VersePreview item) {
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
                if (_hasFrenchData) ...[
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.languageName ?? l10n.adminBibleChapterDefaultLanguageName;
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
                    _field(l10n.adminBibleChapterBookLabel, bookController),
                    const SizedBox(width: AppSpacing.md),
                    if (!isUsfmMode) ...[
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
                ? () => _uploadUsfmFile(ewondoController)
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
                ? () => _uploadUsfmFile(englishController)
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
                ? () => _uploadUsfmFile(frenchController)
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
          if (preview.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.adminBibleChapterComparisonTitle, style: AppTypography.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.adminBibleChapterVersesAcrossChapters(preview.length, _previewChapters.length),
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._previewChapters.map(_chapterPreviewSection),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: isUsfmMode ? l10n.adminBibleChapterSaveBookButton : l10n.adminBibleChapterSaveChapterButton,
              icon: Icons.save_outlined,
              isLoading: isSaving,
              onPressed: saveChapter,
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
