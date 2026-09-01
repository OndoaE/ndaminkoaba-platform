import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show instantiateImageCodec;

import 'package:desktop_drop/desktop_drop.dart';
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
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/clipboard_paste_reader.dart';
import '../../syllabary/data/syllabary_repository.dart';
import '../../syllabary/domain/syllabary_models.dart';

enum _Phase { list, upload, review }

/// What's currently loaded into the upload step, before "Analyze with AI"
/// is pressed — an image, a document (PDF/Word/Excel), or pasted/typed
/// text/table content. Exactly one of [imageOrDocumentBytes] or [text] is
/// set; [isImage] only matters when bytes are set (drives whether a
/// thumbnail + dimensions are shown).
class _PickedContent {
  const _PickedContent.file({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.isImage,
    this.sizeBytes,
    this.imageWidth,
    this.imageHeight,
  }) : text = null;

  const _PickedContent.text(this.text)
      : bytes = null,
        fileName = null,
        mimeType = null,
        isImage = false,
        sizeBytes = null,
        imageWidth = null,
        imageHeight = null;

  final Uint8List? bytes;
  final String? fileName;
  final String? mimeType;
  final bool isImage;
  final int? sizeBytes;
  final int? imageWidth;
  final int? imageHeight;
  final String? text;
}

/// Admin screen for the syllabary/literacy-chart knowledge base: an admin
/// photographs a chart (a consonant with arrows to each vowel, forming
/// syllables — see [SyllabaryExtractionResult]), an AI model extracts it,
/// and only an explicit "Approve & Import" ever writes anything — the
/// extraction step itself never touches the database.
class AdminSyllabaryManagementScreen extends StatefulWidget {
  const AdminSyllabaryManagementScreen({
    super.key,
    required this.languageId,
    this.languageName,
  });

  final String languageId;
  final String? languageName;

  @override
  State<AdminSyllabaryManagementScreen> createState() =>
      _AdminSyllabaryManagementScreenState();
}

class _AdminSyllabaryManagementScreenState
    extends State<AdminSyllabaryManagementScreen> {
  final repository = SyllabaryRepository();

  _Phase phase = _Phase.list;
  bool isLoading = true;
  bool isExtracting = false;
  bool isImporting = false;
  bool isDraggingOver = false;
  List<SyllabaryEntry> entries = [];

  _PickedContent? picked;
  SyllabaryExtractionResult? draft;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getEntries(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        entries = result;
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

  Map<String, List<SyllabaryEntry>> get _grouped {
    final map = <String, List<SyllabaryEntry>>{};
    for (final e in entries) {
      map.putIfAbsent(e.letter, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    }
    return map;
  }

  Future<void> deleteEntry(SyllabaryEntry entry) async {
    try {
      await repository.deleteEntry(entry.id);
      load();
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminSyllabaryMgmtDeleteEntryError));
    }
  }

  Future<void> deleteLetter(String letter, List<SyllabaryEntry> letterEntries) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminSyllabaryMgmtDeleteLetterDialogTitle(letter)),
        content: Text(l10n.adminSyllabaryMgmtDeleteLetterDialogContent(letterEntries.length, letter)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      for (final e in letterEntries) {
        await repository.deleteEntry(e.id);
      }
      load();
      if (!mounted) return;
      _showMessage(l10n.adminSyllabaryMgmtLetterDeletedMessage(letter));
    } on DioException catch (e) {
      if (!mounted) return;
      _showMessage(extractErrorMessage(e, fallback: l10n.adminSyllabaryMgmtDeleteLetterError));
    }
  }

  static const _kAllowedExtensions = ['png', 'jpg', 'jpeg', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'];

  void openUploadPhase() {
    setState(() {
      phase = _Phase.upload;
      picked = null;
    });
  }

  String _guessMimeType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    return 'text/plain';
  }

  Future<(int, int)?> _decodeImageDimensions(Uint8List bytes) async {
    try {
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return (frame.image.width, frame.image.height);
    } catch (_) {
      return null;
    }
  }

  Future<void> _setPickedFile({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final resolvedMimeType = mimeType ?? _guessMimeType(fileName);
    final isImage = resolvedMimeType.startsWith('image/');
    (int, int)? dimensions;
    if (isImage) dimensions = await _decodeImageDimensions(bytes);
    if (!mounted) return;

    if (resolvedMimeType == 'text/plain') {
      // A dropped/picked .txt file is handled identically to pasted text —
      // no need for a server round-trip through the document extractor.
      setState(() => picked = _PickedContent.text(_safeUtf8Decode(bytes)));
      return;
    }

    setState(() {
      picked = _PickedContent.file(
        bytes: bytes,
        fileName: fileName,
        mimeType: resolvedMimeType,
        isImage: isImage,
        sizeBytes: bytes.length,
        imageWidth: dimensions?.$1,
        imageHeight: dimensions?.$2,
      );
    });
  }

  String _safeUtf8Decode(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return '';
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _kAllowedExtensions,
      withData: true,
    );
    final file = result?.files.firstOrNull;
    if (file == null || file.bytes == null) return;
    await _setPickedFile(bytes: file.bytes!, fileName: file.name);
  }

  Future<void> pasteFromClipboard() async {
    final result = await readClipboardPaste();
    if (result == null) {
      final l10n = AppLocalizations.of(context);
      _showMessage(l10n.adminSyllabaryMgmtClipboardEmptyMessage);
      return;
    }
    if (result.isImage) {
      await _setPickedFile(
        bytes: result.imageBytes!,
        fileName: 'pasted-image',
        mimeType: result.imageMimeType,
      );
    } else if (result.text != null) {
      setState(() => picked = _PickedContent.text(result.text!));
    }
  }

  Future<void> handleDroppedFiles(List<DropItem> files) async {
    setState(() => isDraggingOver = false);
    final file = files.firstOrNull;
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _setPickedFile(bytes: bytes, fileName: file.name, mimeType: file.mimeType);
  }

  void clearPicked() => setState(() => picked = null);

  Future<void> analyzeWithAi() async {
    final current = picked;
    if (current == null) return;

    setState(() => isExtracting = true);
    try {
      final SyllabaryExtractionResult result;
      if (current.text != null) {
        result = await repository.extractChartFromText(
          text: current.text!,
          languageId: widget.languageId,
        );
      } else if (current.isImage) {
        result = await repository.extractChartFromImage(
          imageBytes: current.bytes!,
          mimeType: current.mimeType!,
          languageId: widget.languageId,
        );
      } else {
        result = await repository.extractChartFromDocument(
          documentBytes: current.bytes!,
          mimeType: current.mimeType!,
          languageId: widget.languageId,
        );
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        draft = result;
        phase = _Phase.review;
        isExtracting = false;
      });
      if (result.letters.every((g) => g.rows.isEmpty)) {
        _showMessage(l10n.adminSyllabaryMgmtNoRowsDetectedMessage);
      } else if (result.letters.length > 1) {
        _showMessage(l10n.adminSyllabaryMgmtLettersDetectedMessage(result.letters.length));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => isExtracting = false);
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminSyllabaryMgmtAnalyzeError));
    }
  }

  Future<void> reanalyze() async {
    if (picked == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminSyllabaryMgmtReanalyzeDialogTitle),
        content: Text(
          l10n.adminSyllabaryMgmtReanalyzeDialogContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.adminSyllabaryMgmtReanalyzeAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await analyzeWithAi();
  }

  void cancelReview() {
    setState(() {
      phase = _Phase.list;
      draft = null;
      picked = null;
    });
  }

  Future<void> approveAndImport() async {
    final current = draft;
    if (current == null || current.letters.every((g) => g.rows.isEmpty)) return;

    final l10n = AppLocalizations.of(context);
    setState(() => isImporting = true);
    var succeeded = 0;
    var failed = 0;
    String? firstError;
    for (final group in current.letters) {
      for (final row in group.rows) {
        try {
          await repository.createEntry(
            consonant: group.consonant,
            vowel: row.vowel,
            syllable: row.syllable,
            exampleWord: row.exampleWord,
            englishTranslation: row.englishTranslation,
            frenchTranslation: row.frenchTranslation,
            exampleSentence: row.exampleSentence,
            orderNumber: row.orderNumber,
            languageId: widget.languageId,
          );
          succeeded++;
        } on DioException catch (e) {
          failed++;
          firstError ??= extractErrorMessage(e, fallback: l10n.adminSyllabaryMgmtUnknownServerError);
        } catch (e) {
          failed++;
          firstError ??= e.toString();
        }
      }
    }

    if (!mounted) return;
    setState(() {
      isImporting = false;
      phase = _Phase.list;
      draft = null;
      picked = null;
    });
    load();
    _showMessage(
      failed == 0
          ? l10n.adminSyllabaryMgmtImportedMessage(succeeded)
          : l10n.adminSyllabaryMgmtImportedWithFailuresMessage(
              succeeded,
              failed,
              firstError != null ? ' — $firstError' : '',
            ),
    );
  }

  String _titleFor(AppLocalizations l10n, _Phase phase) {
    return switch (phase) {
      _Phase.list => l10n.adminSyllabaryMgmtListTitle,
      _Phase.upload => l10n.adminSyllabaryMgmtUploadChartLabel,
      _Phase.review => l10n.adminSyllabaryMgmtReviewTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: _titleFor(l10n, phase),
        colors: const [AppColors.ai, Color(0xFF6B4CE0)],
        leading: phase == _Phase.upload && !isExtracting
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => phase = _Phase.list),
              )
            : null,
      ),
      floatingActionButton: phase == _Phase.list && !isExtracting
          ? FloatingActionButton.extended(
              onPressed: openUploadPhase,
              icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
              label: Text(
                l10n.adminSyllabaryMgmtUploadChartLabel,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.ai,
            )
          : null,
      body: SafeArea(
        child: isExtracting
            ? _buildExtractingState()
            : switch (phase) {
                _Phase.review => _buildReviewPhase(),
                _Phase.upload => _buildUploadPhase(),
                _Phase.list => _buildListPhase(),
              },
      ),
    );
  }

  Widget _buildExtractingState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminSyllabaryMgmtAnalyzingMessage, style: AppTypography.body),
        ],
      ),
    );
  }

  Widget _buildListPhase() {
    final l10n = AppLocalizations.of(context);
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: ShimmerListLoader(),
      );
    }
    final grouped = _grouped;
    if (grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            l10n.adminSyllabaryMgmtEmptyStateMessage,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final letters = grouped.keys.toList()..sort();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        120,
      ),
      children: [
        for (final letter in letters)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.ai.withValues(alpha: 0.12),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: AppColors.ai,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.adminSyllabaryMgmtSyllableCountLabel(grouped[letter]!.length),
                          style: AppTypography.title,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: l10n.adminSyllabaryMgmtDeleteLetterTooltip(letter),
                        onPressed: () => deleteLetter(letter, grouped[letter]!),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...grouped[letter]!.map(
                    (entry) {
                      final translations = [entry.frenchTranslation, entry.englishTranslation]
                          .whereType<String>()
                          .where((t) => t.isNotEmpty)
                          .join(' / ');
                      return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.syllable,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(entry.exampleWord ?? '—', style: AppTypography.caption),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              translations.isEmpty ? '—' : translations,
                              style: AppTypography.caption,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => deleteEntry(entry),
                          ),
                        ],
                      ),
                    );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadPhase() {
    final l10n = AppLocalizations.of(context);
    final current = picked;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
      children: [
        SectionTitle(
          title: l10n.adminSyllabaryMgmtStep1Title,
          subtitle: l10n.adminSyllabaryMgmtStep1Subtitle,
        ),
        const SizedBox(height: AppSpacing.md),
        DropTarget(
          onDragEntered: (_) => setState(() => isDraggingOver = true),
          onDragExited: (_) => setState(() => isDraggingOver = false),
          onDragDone: (details) => handleDroppedFiles(details.files),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDraggingOver
                  ? AppColors.ai.withValues(alpha: 0.06)
                  : AppColors.surface,
              borderRadius: AppRadius.medium,
              border: Border.all(
                color: isDraggingOver ? AppColors.ai : AppColors.divider,
                width: isDraggingOver ? 2 : 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.content_paste_outlined,
                  size: 40,
                  color: isDraggingOver ? AppColors.ai : AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.adminSyllabaryMgmtDropZoneText,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.adminSyllabaryMgmtSupportedFormatsText,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: pasteFromClipboard,
                      icon: const Icon(Icons.content_paste, size: 16),
                      label: Text(l10n.adminSyllabaryMgmtPasteFromClipboardLabel),
                    ),
                    OutlinedButton.icon(
                      onPressed: pickFile,
                      icon: const Icon(Icons.folder_open_outlined, size: 16),
                      label: Text(l10n.adminSyllabaryMgmtChooseFileLabel),
                    ),
                    if (current != null)
                      OutlinedButton.icon(
                        onPressed: clearPicked,
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        icon: const Icon(Icons.close, size: 16),
                        label: Text(l10n.adminSyllabaryMgmtClearLabel),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (current != null) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionTitle(title: l10n.adminSyllabaryMgmtContentPreviewTitle),
          const SizedBox(height: AppSpacing.md),
          _ContentPreviewCard(content: current),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.adminSyllabaryMgmtAnalyzeWithAiLabel,
            icon: Icons.auto_awesome,
            onPressed: analyzeWithAi,
          ),
        ],
      ],
    );
  }

  Widget _buildReviewPhase() {
    final l10n = AppLocalizations.of(context);
    final current = draft;
    if (current == null) return const SizedBox.shrink();

    final totalRows = current.letters.fold<int>(0, (sum, g) => sum + g.rows.length);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              if (current.warnings.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.adminSyllabaryMgmtExtractionNotesLabel,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...current.warnings.map((w) => Text('• $w', style: AppTypography.caption)),
                    ],
                  ),
                ),
              SectionTitle(
                title: l10n.adminSyllabaryMgmtLettersTitle,
                subtitle: current.letters.isEmpty
                    ? l10n.adminSyllabaryMgmtNoneDetectedLabel
                    : l10n.adminSyllabaryMgmtLettersSummary(current.letters.length, totalRows),
              ),
              const SizedBox(height: AppSpacing.md),
              if (current.letters.isEmpty)
                PremiumCard(
                  child: Text(
                    l10n.adminSyllabaryMgmtNoChartsDetectedMessage,
                    style: AppTypography.caption,
                  ),
                ),
              ...current.letters.asMap().entries.map(
                (groupEntry) => _LetterGroupSection(
                  key: ValueKey(groupEntry.value),
                  group: groupEntry.value,
                  onDeleteGroup: () =>
                      setState(() => current.letters.removeAt(groupEntry.key)),
                  onDeleteRow: (rowIndex) =>
                      setState(() => groupEntry.value.rows.removeAt(rowIndex)),
                  onLetterChanged: (v) => groupEntry.value.consonant =
                      v.trim().isEmpty ? null : v.trim(),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isImporting ? null : cancelReview,
                  child: Text(l10n.commonCancel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isImporting ? null : reanalyze,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.adminSyllabaryMgmtReanalyzeAction),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: l10n.adminSyllabaryMgmtApproveImportLabel,
                  icon: Icons.check,
                  isLoading: isImporting,
                  onPressed: totalRows == 0 ? null : approveAndImport,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The "1. Content Preview" step-2-equivalent shown after something's been
/// pasted/dropped/chosen but before "Analyze with AI" runs — filename,
/// type, size (and dimensions for an image), plus a thumbnail or a text
/// snippet, matching what the admin picked so they can confirm it before
/// spending an AI call on it.
class _ContentPreviewCard extends StatelessWidget {
  const _ContentPreviewCard({required this.content});

  final _PickedContent content;

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (content.text != null) {
      final preview = content.text!.length > 400
          ? '${content.text!.substring(0, 400)}…'
          : content.text!;
      return PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_snippet_outlined, color: AppColors.ai),
                const SizedBox(width: AppSpacing.sm),
                Text(l10n.adminSyllabaryMgmtPastedTextLabel, style: AppTypography.title.copyWith(fontSize: 14)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(preview, style: AppTypography.caption),
          ],
        ),
      );
    }

    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.isImage)
            ClipRRect(
              borderRadius: AppRadius.small,
              child: Image.memory(
                content.bytes!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.ai.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.description_outlined, color: AppColors.ai, size: 32),
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.fileName ?? '—',
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(l10n.adminSyllabaryMgmtTypeLabel(content.mimeType ?? '—'), style: AppTypography.caption),
                if (content.imageWidth != null && content.imageHeight != null)
                  Text(
                    l10n.adminSyllabaryMgmtDimensionsLabel(content.imageWidth!, content.imageHeight!),
                    style: AppTypography.caption,
                  ),
                if (content.sizeBytes != null)
                  Text(l10n.adminSyllabaryMgmtSizeLabel(_formatSize(content.sizeBytes!)), style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One consonant chart's review card: an editable "Letter" field, a delete
/// button for the whole group, and its rows below (reusing
/// [_EditableRowCard]) — one of these is rendered per entry in
/// [SyllabaryExtractionResult.letters], since a single extraction can
/// contain several separate charts (e.g. a page with "F", "H", and "K"
/// charts on it).
class _LetterGroupSection extends StatelessWidget {
  const _LetterGroupSection({
    super.key,
    required this.group,
    required this.onDeleteGroup,
    required this.onDeleteRow,
    required this.onLetterChanged,
  });

  final SyllabaryLetterGroup group;
  final VoidCallback onDeleteGroup;
  final ValueChanged<int> onDeleteRow;
  final ValueChanged<String> onLetterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCard(
            child: Row(
              children: [
                Text(l10n.adminSyllabaryMgmtLetterFieldLabel, style: AppTypography.title),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('letter-${group.hashCode}'),
                    initialValue: group.consonant ?? '',
                    decoration: InputDecoration(
                      hintText: l10n.adminSyllabaryMgmtLetterFieldHint,
                    ),
                    onChanged: onLetterChanged,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: l10n.adminSyllabaryMgmtRemoveLetterTooltip,
                  onPressed: onDeleteGroup,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              l10n.adminSyllabaryMgmtRowCountLabel(group.rows.length),
              style: AppTypography.caption,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (group.rows.isEmpty)
            PremiumCard(
              child: Text(
                l10n.adminSyllabaryMgmtNoRowsForLetterMessage,
                style: AppTypography.caption,
              ),
            )
          else
            ...group.rows.asMap().entries.map(
              (rowEntry) => _EditableRowCard(
                key: ValueKey(rowEntry.value),
                row: rowEntry.value,
                lowConfidence: rowEntry.value.confidence == 'low',
                onDelete: () => onDeleteRow(rowEntry.key),
              ),
            ),
        ],
      ),
    );
  }
}

/// Every field is editable inline — matching the review screen's "you can
/// fix what the AI got wrong before approving" purpose without a separate
/// edit-mode toggle. Edits write straight into the mutable [row] passed in;
/// this widget owns its own [TextEditingController]s so typing never
/// triggers a parent rebuild (only structural changes, like deleting a
/// row, do).
class _EditableRowCard extends StatefulWidget {
  const _EditableRowCard({
    super.key,
    required this.row,
    required this.lowConfidence,
    required this.onDelete,
  });

  final SyllabaryExtractionRow row;
  final bool lowConfidence;
  final VoidCallback onDelete;

  @override
  State<_EditableRowCard> createState() => _EditableRowCardState();
}

class _EditableRowCardState extends State<_EditableRowCard> {
  late final vowelController = TextEditingController(text: widget.row.vowel);
  late final syllableController = TextEditingController(text: widget.row.syllable);
  late final wordController = TextEditingController(text: widget.row.exampleWord ?? '');
  late final frenchTranslationController =
      TextEditingController(text: widget.row.frenchTranslation ?? '');
  late final englishTranslationController =
      TextEditingController(text: widget.row.englishTranslation ?? '');
  late final exampleController =
      TextEditingController(text: widget.row.exampleSentence ?? '');

  @override
  void dispose() {
    vowelController.dispose();
    syllableController.dispose();
    wordController.dispose();
    frenchTranslationController.dispose();
    englishTranslationController.dispose();
    exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.lowConfidence ? AppColors.warning : AppColors.divider,
          width: widget.lowConfidence ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.lowConfidence)
                const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.xs),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              Expanded(
                child: Text(
                  l10n.adminSyllabaryMgmtRowNumberLabel(widget.row.orderNumber + 1),
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: l10n.adminSyllabaryMgmtRemoveRowTooltip,
                onPressed: widget.onDelete,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: vowelController,
                  decoration: InputDecoration(labelText: l10n.adminSyllabaryMgmtVowelLabel, isDense: true),
                  onChanged: (v) => widget.row.vowel = v,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: syllableController,
                  decoration: InputDecoration(labelText: l10n.adminSyllabaryMgmtSyllableLabel, isDense: true),
                  onChanged: (v) => widget.row.syllable = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: wordController,
            decoration: InputDecoration(labelText: l10n.adminSyllabaryMgmtExampleWordLabel, isDense: true),
            onChanged: (v) => widget.row.exampleWord = v.isEmpty ? null : v,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: frenchTranslationController,
            decoration: InputDecoration(
              labelText: l10n.adminSyllabaryMgmtFrenchTranslationLabel,
              isDense: true,
            ),
            onChanged: (v) => widget.row.frenchTranslation = v.isEmpty ? null : v,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: englishTranslationController,
            decoration: InputDecoration(
              labelText: l10n.adminSyllabaryMgmtEnglishTranslationLabel,
              isDense: true,
            ),
            onChanged: (v) => widget.row.englishTranslation = v.isEmpty ? null : v,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: exampleController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.adminSyllabaryMgmtExampleSentenceLabel,
              isDense: true,
            ),
            onChanged: (v) => widget.row.exampleSentence = v.isEmpty ? null : v,
          ),
        ],
      ),
    );
  }
}
