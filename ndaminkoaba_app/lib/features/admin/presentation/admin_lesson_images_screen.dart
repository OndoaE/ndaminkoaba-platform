import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../lessons/domain/models/lesson_image.dart';
import '../data/content_repository.dart';

class AdminLessonImagesScreen extends StatefulWidget {
  const AdminLessonImagesScreen({super.key, required this.lessonId, this.lessonTitle});

  final String lessonId;
  final String? lessonTitle;

  @override
  State<AdminLessonImagesScreen> createState() => _AdminLessonImagesScreenState();
}

class _AdminLessonImagesScreenState extends State<AdminLessonImagesScreen> {
  final repository = ContentRepository();
  final picker = ImagePicker();

  bool isLoading = true;
  bool isUploading = false;
  List<LessonImage> images = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getLessonImages(widget.lessonId);
      if (!mounted) return;
      setState(() {
        images = result;
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

  Future<void> addImage() async {
    final l10n = AppLocalizations.of(context);
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    final result = await showDialog<_ImageFormResult>(
      context: context,
      builder: (context) => _ImageFormDialog(previewBytes: bytes),
    );
    if (result == null) return;

    setState(() => isUploading = true);
    try {
      final url = await repository.uploadImage(bytes, picked.name);
      await repository.createLessonImage(
        lessonId: widget.lessonId,
        imageUrl: url,
        word: result.word,
        caption: result.caption,
        orderNumber: images.length + 1,
      );
      await load();
      _showMessage(l10n.adminLessonImagesAddedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminLessonImagesAddError));
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> deleteImage(LessonImage image) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.adminLessonImagesDeleteTitle),
          content: Text(l10n.adminLessonImagesDeleteBody(image.word)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.adminLessonImagesCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.adminLessonImagesDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      await repository.deleteLessonImage(image.id);
      load();
      _showMessage(l10n.adminLessonImagesRemovedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminLessonImagesRemoveError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: widget.lessonTitle != null
            ? l10n.adminLessonImagesTitleWithLesson(widget.lessonTitle!)
            : l10n.adminLessonImagesTitleFallback,
        colors: const [Color(0xFFB5312B), AppColors.primary],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB5312B),
        icon: isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
        label: Text(l10n.adminLessonImagesAddImage, style: const TextStyle(color: Colors.white)),
        onPressed: isUploading ? null : addImage,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.adminLessonImagesIntro,
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const ShimmerListLoader()
                    : images.isEmpty
                        ? EmptyState(
                            icon: Icons.image_outlined,
                            title: l10n.adminLessonImagesEmptyTitle,
                            message: l10n.adminLessonImagesEmptyMessage,
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.md,
                              crossAxisSpacing: AppSpacing.md,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final image = images[index];
                              return PremiumCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                        child: Image.network(
                                          AppConfig.resolveUrl(image.imageUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: AppColors.surface,
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.broken_image_outlined),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  image.word,
                                                  style: AppTypography.title.copyWith(fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (image.caption != null && image.caption!.isNotEmpty)
                                                  Text(
                                                    image.caption!,
                                                    style: AppTypography.caption,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                            tooltip: l10n.adminLessonImagesDelete,
                                            onPressed: () => deleteImage(image),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageFormResult {
  const _ImageFormResult({required this.word, this.caption});

  final String word;
  final String? caption;
}

class _ImageFormDialog extends StatefulWidget {
  const _ImageFormDialog({required this.previewBytes});

  final Uint8List previewBytes;

  @override
  State<_ImageFormDialog> createState() => _ImageFormDialogState();
}

class _ImageFormDialogState extends State<_ImageFormDialog> {
  final wordController = TextEditingController();
  final captionController = TextEditingController();

  @override
  void dispose() {
    wordController.dispose();
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.adminLessonImagesDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppRadius.medium,
              child: Image.memory(widget.previewBytes, height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: wordController,
              decoration: InputDecoration(labelText: l10n.adminLessonImagesWordLabel),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: captionController,
              decoration: InputDecoration(labelText: l10n.adminLessonImagesCaptionLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.adminLessonImagesCancel)),
        FilledButton(
          onPressed: () {
            if (wordController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              _ImageFormResult(
                word: wordController.text.trim(),
                caption: captionController.text.trim(),
              ),
            );
          },
          child: Text(l10n.adminLessonImagesAdd),
        ),
      ],
    );
  }
}
