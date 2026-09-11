import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../bible/domain/models/bible_verse.dart';
import '../data/knowledge_repository.dart';
import '../domain/knowledge_models.dart';

/// Manages the hero banner photo and per-book cover photos shown on the
/// learner Bible screen — reached via a button on [AdminBibleChapterScreen]
/// rather than folded into it, since that screen is entirely
/// chapter/verse-content-oriented with no per-book metadata section.
class AdminBibleImagesScreen extends StatefulWidget {
  const AdminBibleImagesScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminBibleImagesScreen> createState() => _AdminBibleImagesScreenState();
}

class _AdminBibleImagesScreenState extends State<AdminBibleImagesScreen> {
  final repository = KnowledgeRepository();

  bool isLoading = true;
  BibleHeroImageEntry? hero;
  List<BibleBookCoverEntry> covers = [];
  List<String> otherBookKeys = [];

  bool isUploadingHero = false;
  String? uploadingBookKey;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        repository.getBibleImages(languageId: widget.languageId),
        repository.getBibleChapters(languageId: widget.languageId),
      ]);
      if (!mounted) return;
      final images = results[0] as ({BibleHeroImageEntry? hero, List<BibleBookCoverEntry> covers});
      final chapters = results[1] as List<BibleChapterSummary>;
      final others = <String>{};
      for (final c in chapters) {
        if (matchGospelBook(c.book) == null) others.add(c.book);
      }
      setState(() {
        hero = images.hero;
        covers = images.covers;
        otherBookKeys = others.toList()..sort();
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

  String? _coverUrlFor(String bookKey) {
    for (final cover in covers) {
      if (cover.bookKey == bookKey) return cover.coverUrl;
    }
    return null;
  }

  String? _coverIdFor(String bookKey) {
    for (final cover in covers) {
      if (cover.bookKey == bookKey) return cover.id;
    }
    return null;
  }

  Future<void> _uploadHero() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => isUploadingHero = true);
    try {
      final url = await repository.uploadImage(bytes, picked.name);
      await repository.upsertBibleHeroImage(languageId: widget.languageId, imageUrl: url);
      if (!mounted) return;
      await load();
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBibleImagesUploadError));
    } finally {
      if (mounted) setState(() => isUploadingHero = false);
    }
  }

  Future<void> _removeHero() async {
    final current = hero;
    if (current == null) return;
    try {
      await repository.deleteBibleHeroImage(current.id);
      if (!mounted) return;
      setState(() => hero = null);
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBibleImagesRemoveError));
    }
  }

  Future<void> _uploadCover(String bookKey) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => uploadingBookKey = bookKey);
    try {
      final url = await repository.uploadImage(bytes, picked.name);
      await repository.upsertBibleBookCover(
        languageId: widget.languageId,
        bookKey: bookKey,
        coverUrl: url,
      );
      await load();
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBibleImagesUploadError));
    } finally {
      if (mounted) setState(() => uploadingBookKey = null);
    }
  }

  Future<void> _removeCover(String bookKey) async {
    final id = _coverIdFor(bookKey);
    if (id == null) return;
    try {
      await repository.deleteBibleBookCover(id);
      if (!mounted) return;
      setState(() => covers = covers.where((c) => c.id != id).toList());
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBibleImagesRemoveError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final title = widget.languageName ?? l10n.adminBibleChapterDefaultLanguageName;

    return AdminShell(
      activeNavKey: 'bible',
      languageId: widget.languageId,
      languageName: title,
      title: l10n.adminBibleImagesTitle,
      subtitle: l10n.adminBibleImagesSubtitle(title),
      child: isLoading
          ? const ShimmerListLoader(itemCount: 4, itemHeight: 80)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.adminBibleImagesHeroSectionTitle, style: AppTypography.title),
                const SizedBox(height: 2),
                Text(l10n.adminBibleImagesHeroSectionSubtitle, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.md),
                _ImageRow(
                  label: l10n.bibleHeroHeadline,
                  imageUrl: hero?.imageUrl,
                  isUploading: isUploadingHero,
                  onUpload: _uploadHero,
                  onRemove: hero == null ? null : _removeHero,
                  uploadLabel: hero == null ? l10n.adminBibleImagesUploadLabel : l10n.adminBibleImagesReplaceLabel,
                  removeLabel: l10n.adminBibleImagesRemoveLabel,
                  uploadingLabel: l10n.adminBibleImagesUploadingLabel,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.adminBibleImagesBookCoversSectionTitle, style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.adminBibleImagesGospelsGroupLabel, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                for (final gospel in GospelBook.values) ...[
                  _ImageRow(
                    label: isFrench ? gospel.displayNameFr : gospel.displayNameEn,
                    imageUrl: _coverUrlFor(gospel.name.toUpperCase()),
                    isUploading: uploadingBookKey == gospel.name.toUpperCase(),
                    onUpload: () => _uploadCover(gospel.name.toUpperCase()),
                    onRemove: _coverUrlFor(gospel.name.toUpperCase()) == null
                        ? null
                        : () => _removeCover(gospel.name.toUpperCase()),
                    uploadLabel: _coverUrlFor(gospel.name.toUpperCase()) == null
                        ? l10n.adminBibleImagesUploadLabel
                        : l10n.adminBibleImagesReplaceLabel,
                    removeLabel: l10n.adminBibleImagesRemoveLabel,
                    uploadingLabel: l10n.adminBibleImagesUploadingLabel,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(l10n.adminBibleImagesOtherBooksGroupLabel, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                if (otherBookKeys.isEmpty)
                  Text(l10n.adminBibleImagesNoOtherBooksMessage, style: AppTypography.caption)
                else
                  for (final bookKey in otherBookKeys) ...[
                    _ImageRow(
                      label: bookKey,
                      imageUrl: _coverUrlFor(bookKey),
                      isUploading: uploadingBookKey == bookKey,
                      onUpload: () => _uploadCover(bookKey),
                      onRemove: _coverUrlFor(bookKey) == null ? null : () => _removeCover(bookKey),
                      uploadLabel: _coverUrlFor(bookKey) == null
                          ? l10n.adminBibleImagesUploadLabel
                          : l10n.adminBibleImagesReplaceLabel,
                      removeLabel: l10n.adminBibleImagesRemoveLabel,
                      uploadingLabel: l10n.adminBibleImagesUploadingLabel,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            ),
    );
  }
}

class _ImageRow extends StatelessWidget {
  const _ImageRow({
    required this.label,
    required this.imageUrl,
    required this.isUploading,
    required this.onUpload,
    required this.onRemove,
    required this.uploadLabel,
    required this.removeLabel,
    required this.uploadingLabel,
  });

  final String label;
  final String? imageUrl;
  final bool isUploading;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;
  final String uploadLabel;
  final String removeLabel;
  final String uploadingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.small,
            child: (imageUrl == null || imageUrl!.isEmpty)
                ? Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(gradient: AppGradients.scripture),
                    alignment: Alignment.center,
                    child: const Icon(Icons.auto_stories, color: Colors.white, size: 24),
                  )
                : Image.network(
                    AppConfig.resolveUrl(imageUrl!),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(gradient: AppGradients.scripture),
                      alignment: Alignment.center,
                      child: const Icon(Icons.auto_stories, color: Colors.white, size: 24),
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: AppTypography.title.copyWith(fontSize: 14)),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (onRemove != null)
            IconButton(
              onPressed: isUploading ? null : onRemove,
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: removeLabel,
              color: AppColors.error,
            ),
          OutlinedButton.icon(
            onPressed: isUploading ? null : onUpload,
            icon: const Icon(Icons.image_outlined, size: 16),
            label: Text(isUploading ? uploadingLabel : uploadLabel),
          ),
        ],
      ),
    );
  }
}
