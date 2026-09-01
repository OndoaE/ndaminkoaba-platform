import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/book_repository.dart';
import '../data/content_repository.dart';
import '../domain/book_models.dart';

const _bookAccent = [Color(0xFF5D4037), Color(0xFF8D6E63)];
const _kLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

String _levelLabel(AppLocalizations l10n, String level) {
  return switch (level) {
    'BEGINNER' => l10n.adminLevelBeginner,
    'INTERMEDIATE' => l10n.adminLevelIntermediate,
    'ADVANCED' => l10n.adminLevelAdvanced,
    _ => level,
  };
}

class AdminBookEditorScreen extends StatefulWidget {
  const AdminBookEditorScreen({super.key, required this.bookId, this.bookTitle});

  final String bookId;
  final String? bookTitle;

  @override
  State<AdminBookEditorScreen> createState() => _AdminBookEditorScreenState();
}

class _AdminBookEditorScreenState extends State<AdminBookEditorScreen> {
  final repository = BookRepository();
  final contentRepository = ContentRepository();

  bool isLoading = true;
  bool isSaving = false;
  AdminBook? book;
  List<AdminBookPage> pages = [];

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final descriptionController = TextEditingController();
  final frenchDescriptionController = TextEditingController();
  final readingTimeController = TextEditingController();
  final recommendedAgeController = TextEditingController();

  String? category;
  String? level;
  bool hasImages = false;
  String? coverUrl;
  bool isUploadingCover = false;

  /// 'file' or 'pages' — which content path this book uses. Both are
  /// optional server-side; the admin picks one per book.
  String contentMode = 'file';
  String? fileUrl;
  String? fileType;
  bool isUploadingFile = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    frenchDescriptionController.dispose();
    readingTimeController.dispose();
    recommendedAgeController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        repository.getBook(widget.bookId),
        repository.getPages(widget.bookId),
      ]);
      if (!mounted) return;
      final fetchedBook = results[0] as AdminBook;
      final fetchedPages = results[1] as List<AdminBookPage>;
      setState(() {
        book = fetchedBook;
        pages = fetchedPages;
        titleController.text = fetchedBook.title;
        authorController.text = fetchedBook.author ?? '';
        descriptionController.text = fetchedBook.description ?? '';
        frenchDescriptionController.text = fetchedBook.frenchDescription ?? '';
        readingTimeController.text = fetchedBook.readingTimeMinutes?.toString() ?? '';
        recommendedAgeController.text = fetchedBook.recommendedAge?.toString() ?? '';
        category = fetchedBook.category;
        level = fetchedBook.level;
        hasImages = fetchedBook.hasImages;
        coverUrl = fetchedBook.coverUrl;
        fileUrl = fetchedBook.fileUrl;
        fileType = fetchedBook.fileType;
        contentMode = fetchedBook.fileUrl != null || fetchedPages.isEmpty ? 'file' : 'pages';
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

  Future<void> _uploadCover() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => isUploadingCover = true);
    try {
      final url = await repository.uploadCoverImage(bytes, picked.name);
      if (!mounted) return;
      setState(() => coverUrl = url);
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorUploadCoverError));
    } finally {
      if (mounted) setState(() => isUploadingCover = false);
    }
  }

  Future<void> _uploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
      withData: true,
    );
    final picked = result?.files.firstOrNull;
    if (picked == null || picked.bytes == null) return;
    setState(() => isUploadingFile = true);
    try {
      final uploaded = await repository.uploadBookFile(picked.bytes!, picked.name);
      if (!mounted) return;
      setState(() {
        fileUrl = uploaded.url;
        fileType = uploaded.fileType;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorUploadFileError));
    } finally {
      if (mounted) setState(() => isUploadingFile = false);
    }
  }

  Future<void> _save() async {
    setState(() => isSaving = true);
    try {
      await repository.updateBook(
        widget.bookId,
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        description: descriptionController.text.trim(),
        frenchDescription: frenchDescriptionController.text.trim(),
        coverUrl: coverUrl,
        fileUrl: contentMode == 'file' ? fileUrl : null,
        fileType: contentMode == 'file' ? fileType : null,
        category: category,
        level: level,
        readingTimeMinutes: int.tryParse(readingTimeController.text.trim()),
        recommendedAge: int.tryParse(recommendedAgeController.text.trim()),
        hasImages: hasImages,
      );
      await load();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(l10n.adminBookEditorBookSavedMessage);
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorSaveBookError));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _addPage() async {
    try {
      await repository.createPage(
        bookId: widget.bookId,
        orderNumber: pages.length + 1,
        ewondoText: '',
      );
      await load();
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorAddPageError));
    }
  }

  Future<void> _deletePage(AdminBookPage page) async {
    try {
      await repository.deletePage(page.id);
      await load();
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorDeletePageError));
    }
  }

  Future<void> _movePage(int index, int delta) async {
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= pages.length) return;
    final ids = pages.map((p) => p.id).toList();
    final moved = ids.removeAt(index);
    ids.insert(newIndex, moved);
    try {
      await repository.reorderPages(widget.bookId, ids);
      await load();
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorReorderPagesError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminShell(
      activeNavKey: 'books',
      languageId: book?.languageId,
      title: l10n.adminBookEditorTitle,
      subtitle: book?.title ?? widget.bookTitle ?? '',
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: isSaving ? null : _save,
          child: Text(isSaving ? l10n.adminBookEditorSavingEllipsisLabel : l10n.commonSave),
        ),
      ],
      child: isLoading
          ? const ShimmerListLoader(itemCount: 5, itemHeight: 100)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildContentCard(),
              ],
            ),
    );
  }

  Widget _buildDetailsCard() {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminBookEditorDetailsTitle, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.adminBookEditorTitleFieldLabel)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: authorController,
            decoration: InputDecoration(labelText: l10n.adminBookEditorAuthorFieldLabel),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            minLines: 2,
            decoration: InputDecoration(labelText: l10n.adminBookEditorDescriptionFieldLabel),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: frenchDescriptionController,
            maxLines: 3,
            minLines: 2,
            decoration: InputDecoration(
              labelText: l10n.adminBookEditorFrenchDescriptionLabel,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminBookEditorCoverImageLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coverUrl != null && coverUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: AppRadius.small,
                  child: Image.network(
                    AppConfig.resolveUrl(coverUrl!),
                    width: 64,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: isUploadingCover ? null : _uploadCover,
                icon: const Icon(Icons.image_outlined, size: 16),
                label: Text(isUploadingCover ? '…' : l10n.adminBookEditorChangeCoverLabel),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminBookEditorCategoryLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final c in kBookCategories)
                ChoiceChip(
                  label: Text(bookCategoryLabel(c)),
                  selected: category == c,
                  onSelected: (_) => setState(() => category = c),
                  selectedColor: _bookAccent[0],
                  labelStyle: TextStyle(color: category == c ? Colors.white : AppColors.textPrimary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminBookEditorLevelLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final l in _kLevels)
                ChoiceChip(
                  label: Text(_levelLabel(l10n, l)),
                  selected: level == l,
                  onSelected: (_) => setState(() => level = l),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: level == l ? Colors.white : AppColors.textPrimary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: readingTimeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.adminBookEditorReadingTimeLabel),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: recommendedAgeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.adminBookEditorRecommendedAgeLabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            value: hasImages,
            onChanged: (v) => setState(() => hasImages = v ?? false),
            title: Text(l10n.adminBookEditorContainsIllustrationsLabel),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminBookEditorContentTitle, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'file', label: Text(l10n.adminBookEditorUploadedFileSegmentLabel), icon: const Icon(Icons.attach_file, size: 16)),
              ButtonSegment(value: 'pages', label: Text(l10n.adminBookEditorAuthoredPagesSegmentLabel), icon: const Icon(Icons.auto_stories_outlined, size: 16)),
            ],
            selected: {contentMode},
            onSelectionChanged: (s) => setState(() => contentMode = s.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (contentMode == 'file') _buildFileMode() else _buildPagesMode(),
        ],
      ),
    );
  }

  Widget _buildFileMode() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fileUrl != null && fileUrl!.isNotEmpty)
          Text(l10n.adminBookEditorCurrentFileLabel(fileType?.toUpperCase() ?? '', fileUrl!), style: AppTypography.caption)
        else
          Text(l10n.adminBookEditorNoFileUploadedMessage, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: isUploadingFile ? null : _uploadFile,
          icon: const Icon(Icons.attach_file, size: 16),
          label: Text(isUploadingFile ? '…' : (fileUrl != null ? l10n.adminBookEditorReplaceFileLabel : l10n.adminBookEditorUploadFileLabel)),
        ),
      ],
    );
  }

  Widget _buildPagesMode() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pages.isEmpty)
          Text(l10n.adminBookEditorNoPagesMessage, style: AppTypography.caption)
        else
          for (var i = 0; i < pages.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _BookPageCard(
                key: ValueKey(pages[i].id),
                page: pages[i],
                index: i,
                total: pages.length,
                onMove: (delta) => _movePage(i, delta),
                onDelete: () => _deletePage(pages[i]),
                onSaved: load,
                onShowMessage: _showMessage,
              ),
            ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _addPage,
          icon: const Icon(Icons.add, size: 16),
          label: Text(l10n.adminBookEditorAddPageLabel),
        ),
      ],
    );
  }
}

class _BookPageCard extends StatefulWidget {
  const _BookPageCard({
    super.key,
    required this.page,
    required this.index,
    required this.total,
    required this.onMove,
    required this.onDelete,
    required this.onSaved,
    required this.onShowMessage,
  });

  final AdminBookPage page;
  final int index;
  final int total;
  final ValueChanged<int> onMove;
  final VoidCallback onDelete;
  final VoidCallback onSaved;
  final ValueChanged<String> onShowMessage;

  @override
  State<_BookPageCard> createState() => _BookPageCardState();
}

class _BookPageCardState extends State<_BookPageCard> {
  late final ewondoController = TextEditingController(text: widget.page.ewondoText);
  late final englishController = TextEditingController(text: widget.page.englishText);
  late final frenchController = TextEditingController(text: widget.page.frenchText);
  late String? illustrationUrl = widget.page.illustrationUrl;
  late String? audioUrl = widget.page.audioUrl;
  bool isSaving = false;
  bool isUploadingImage = false;
  bool isUploadingAudio = false;

  @override
  void dispose() {
    ewondoController.dispose();
    englishController.dispose();
    frenchController.dispose();
    super.dispose();
  }

  Future<void> _uploadIllustration() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final Uint8List bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => isUploadingImage = true);
    try {
      final url = await ContentRepository().uploadImage(bytes, picked.name);
      if (!mounted) return;
      setState(() => illustrationUrl = url);
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      widget.onShowMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorUploadIllustrationError));
    } finally {
      if (mounted) setState(() => isUploadingImage = false);
    }
  }

  Future<void> _uploadAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
      withData: true,
    );
    final picked = result?.files.firstOrNull;
    if (picked == null || picked.bytes == null) return;
    setState(() => isUploadingAudio = true);
    try {
      final url = await ContentRepository().uploadAudio(picked.bytes!, picked.name);
      if (!mounted) return;
      setState(() => audioUrl = url);
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      widget.onShowMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorUploadAudioError));
    } finally {
      if (mounted) setState(() => isUploadingAudio = false);
    }
  }

  Future<void> _save() async {
    setState(() => isSaving = true);
    try {
      await BookRepository().updatePage(
        widget.page.id,
        ewondoText: ewondoController.text.trim(),
        englishText: englishController.text.trim(),
        frenchText: frenchController.text.trim(),
        illustrationUrl: illustrationUrl ?? '',
        audioUrl: audioUrl ?? '',
      );
      widget.onSaved();
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      widget.onShowMessage(extractErrorMessage(e, fallback: l10n.adminBookEditorSavePageError));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.adminBookEditorPageNumberLabel(widget.index + 1), style: AppTypography.title.copyWith(fontSize: 14)),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 18),
                onPressed: widget.index == 0 ? null : () => widget.onMove(-1),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: widget.index == widget.total - 1 ? null : () => widget.onMove(1),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (illustrationUrl != null && illustrationUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: AppRadius.small,
                  child: Image.network(
                    AppConfig.resolveUrl(illustrationUrl!),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isUploadingImage ? null : _uploadIllustration,
                      icon: const Icon(Icons.image_outlined, size: 14),
                      label: Text(isUploadingImage ? '…' : l10n.adminBookEditorIllustrationLabel, style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    OutlinedButton.icon(
                      onPressed: isUploadingAudio ? null : _uploadAudio,
                      icon: const Icon(Icons.graphic_eq, size: 14),
                      label: Text(
                        isUploadingAudio ? '…' : (audioUrl != null ? l10n.adminBookEditorReplaceAudioLabel : l10n.adminBookEditorAudioOptionalLabel),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: ewondoController,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.adminBookEditorEwondoTextLabel),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: englishController,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.adminBookEditorEnglishTranslationLabel),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: frenchController,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.adminBookEditorFrenchTranslationLabel),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: isSaving ? null : _save,
              child: Text(isSaving ? l10n.adminBookEditorSavingEllipsisLabel : l10n.adminBookEditorSavePageLabel),
            ),
          ),
        ],
      ),
    );
  }
}
