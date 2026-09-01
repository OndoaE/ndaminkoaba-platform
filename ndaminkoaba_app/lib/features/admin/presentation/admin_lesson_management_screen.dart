import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/lesson_content_preview.dart';
import '../../../design_system/widgets/markdown_formatting_toolbar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/content_repository.dart';
import '../domain/management_models.dart';
import 'widgets/move_lesson_dialog.dart';
import 'widgets/reorder_lesson_dialog.dart';

/// The conversation editor uses one plain-text line per turn — "Speaker:
/// Text || French text" — rather than a dynamic add/remove-row widget,
/// since that's much faster for an admin to author/edit than a form with
/// per-line buttons, and still round-trips cleanly to/from the
/// `[{speaker, text, frenchText}]` JSON the lesson screen renders.
String conversationToLines(List<Map<String, dynamic>> conversation) {
  return conversation.map((line) {
    final speaker = line['speaker'] ?? '';
    final text = line['text'] ?? '';
    final frenchText = line['frenchText'] as String?;
    return (frenchText != null && frenchText.isNotEmpty)
        ? '$speaker: $text || $frenchText'
        : '$speaker: $text';
  }).join('\n');
}

List<Map<String, dynamic>> linesToConversation(String lines) {
  return lines
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && line.contains(':'))
      .map((line) {
        final colonIndex = line.indexOf(':');
        final speaker = line.substring(0, colonIndex).trim();
        final rest = line.substring(colonIndex + 1).trim();
        final parts = rest.split('||');
        final text = parts[0].trim();
        final frenchText = parts.length > 1 ? parts[1].trim() : null;
        return {
          'speaker': speaker,
          'text': text,
          if (frenchText != null && frenchText.isNotEmpty) 'frenchText': frenchText,
        };
      })
      .toList();
}

class AdminLessonManagementScreen extends StatefulWidget {
  const AdminLessonManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminLessonManagementScreen> createState() => _AdminLessonManagementScreenState();
}

class _AdminLessonManagementScreenState extends State<AdminLessonManagementScreen> {
  final contentRepository = ContentRepository();
  final searchController = TextEditingController();

  bool isLoading = true;
  List<ManagedLesson> lessons = [];
  List<ManagedModule> modules = [];
  String? courseFilter;

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
        contentRepository.getAllLessonsFlat(languageId: widget.languageId),
        contentRepository.getAllModulesFlat(languageId: widget.languageId),
      ]);
      if (!mounted) return;
      setState(() {
        lessons = results[0] as List<ManagedLesson>;
        modules = results[1] as List<ManagedModule>;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<String> get _courseTitles => lessons.map((l) => l.courseTitle).toSet().toList()..sort();

  List<ManagedLesson> get _visible {
    final query = searchController.text.trim().toLowerCase();
    final list = lessons.where((l) {
      final matchesCourse = courseFilter == null || l.courseTitle == courseFilter;
      final matchesQuery = query.isEmpty || l.title.toLowerCase().contains(query);
      return matchesCourse && matchesQuery;
    }).toList();
    list.sort((a, b) {
      final courseCompare = a.courseTitle.compareTo(b.courseTitle);
      if (courseCompare != 0) return courseCompare;
      final moduleCompare = a.moduleTitle.compareTo(b.moduleTitle);
      if (moduleCompare != 0) return moduleCompare;
      return a.orderNumber.compareTo(b.orderNumber);
    });
    return list;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> editLesson(ManagedLesson lesson) async {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController(text: lesson.title);
    final summaryController = TextEditingController(text: lesson.summary);
    final contentController = SmartListTextEditingController(text: lesson.content);
    final frenchTitleController = TextEditingController(text: lesson.frenchTitle ?? '');
    final frenchSummaryController = TextEditingController(text: lesson.frenchSummary ?? '');
    final frenchContentController = SmartListTextEditingController(text: lesson.frenchContent ?? '');
    final conversationController =
        TextEditingController(text: conversationToLines(lesson.conversation));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.adminEditLessonTitle(lesson.title)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.adminFieldTitle)),
                const SizedBox(height: AppSpacing.md),
                TextField(controller: summaryController, decoration: InputDecoration(labelText: l10n.adminFieldSummary)),
                const SizedBox(height: AppSpacing.md),
                const MarkdownHint(),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: l10n.adminFieldContent),
                  onChanged: (_) => setDialogState(() {}),
                  contextMenuBuilder: markdownFormattingContextMenuBuilder(contentController),
                ),
                const SizedBox(height: AppSpacing.sm),
                LessonContentPreview(text: contentController.text),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: frenchTitleController,
                  decoration: InputDecoration(labelText: l10n.adminFrenchTitleOptionalLabel),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: frenchSummaryController,
                  decoration: InputDecoration(labelText: l10n.adminLessonMgmtFrenchSummaryOptionalLabel),
                ),
                const SizedBox(height: AppSpacing.md),
                const MarkdownHint(),
                TextField(
                  controller: frenchContentController,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: l10n.adminLessonMgmtFrenchContentOptionalLabel),
                  onChanged: (_) => setDialogState(() {}),
                  contextMenuBuilder: markdownFormattingContextMenuBuilder(frenchContentController),
                ),
                const SizedBox(height: AppSpacing.sm),
                LessonContentPreview(text: frenchContentController.text),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.adminLessonMgmtConversationHelpText,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: conversationController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.adminLessonMgmtConversationLabel,
                    hintText: l10n.adminLessonMgmtConversationHint,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonSave)),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    if (contentController.text.trim().length < 10) {
      _showMessage(l10n.adminLessonContentMinLengthError);
      return;
    }

    try {
      await contentRepository.updateLesson(
        lesson.id,
        title: titleController.text.trim(),
        summary: summaryController.text.trim(),
        content: contentController.text.trim(),
        frenchTitle: frenchTitleController.text.trim(),
        frenchSummary: frenchSummaryController.text.trim(),
        frenchContent: frenchContentController.text.trim(),
        conversationJson: linesToConversation(conversationController.text),
      );
      load();
      _showMessage(l10n.adminLessonMgmtUpdatedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotUpdateLesson));
    }
  }

  Future<void> moveLesson(ManagedLesson lesson) async {
    final l10n = AppLocalizations.of(context);
    final result = await showMoveLessonDialog(
      context: context,
      modules: modules,
      currentModuleId: lesson.moduleId,
    );
    if (result == null) return;

    try {
      await contentRepository.updateLesson(
        lesson.id,
        moduleId: result.moduleId,
        orderNumber: result.orderNumber,
      );
      load();
      _showMessage(l10n.adminLessonMgmtMovedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotMoveLesson));
    }
  }

  List<ManagedLesson> _siblings(ManagedLesson lesson) =>
      lessons.where((l) => l.moduleId == lesson.moduleId).toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

  Future<void> reorderLesson(ManagedLesson lesson) async {
    final l10n = AppLocalizations.of(context);
    final siblings = _siblings(lesson);
    final currentIndex = siblings.indexWhere((l) => l.id == lesson.id);

    final newPosition = await showReorderLessonDialog(
      context: context,
      currentPosition: currentIndex + 1,
      totalLessons: siblings.length,
    );
    if (newPosition == null) return;
    final toIndex = newPosition - 1;
    if (toIndex == currentIndex) return;

    final changes = reorderLessonPositions(
      lessons: siblings.map((l) => (id: l.id, orderNumber: l.orderNumber)).toList(),
      fromIndex: currentIndex,
      toIndex: toIndex,
    );

    try {
      for (final entry in changes.entries) {
        await contentRepository.updateLesson(entry.key, orderNumber: entry.value);
      }
      load();
      _showMessage(l10n.adminLessonMgmtReorderedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotReorderLesson));
    }
  }

  Future<void> deleteLesson(ManagedLesson lesson) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminLessonMgmtDeleteLessonTitle),
        content: Text(
          lesson.hasQuiz
              ? l10n.adminLessonMgmtDeleteConfirmWithQuiz(lesson.title)
              : l10n.adminLessonMgmtDeleteConfirm(lesson.title),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
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
      await contentRepository.deleteLesson(lesson.id);
      load();
      _showMessage(l10n.adminLessonMgmtDeletedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotDeleteLesson));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: l10n.adminLessonMgmtAppBarTitle, colors: const [Color(0xFF3D6BE0), AppColors.primary]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3D6BE0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.adminQuickActionNewLesson, style: const TextStyle(color: Colors.white)),
        onPressed: () async {
          await context.push(
            '/admin/languages/${widget.languageId}/lessons/new',
            extra: widget.languageName,
          );
          load();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.adminLessonMgmtSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_courseTitles.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: l10n.adminLessonMgmtAllCoursesFilter,
                        selected: courseFilter == null,
                        onTap: () => setState(() => courseFilter = null),
                      ),
                      ..._courseTitles.map(
                        (title) => Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: _FilterChip(
                            label: title,
                            selected: courseFilter == title,
                            onTap: () => setState(() => courseFilter = title),
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
                    : _visible.isEmpty
                        ? Center(child: Text(l10n.adminLessonMgmtNoLessonsFoundMessage, style: AppTypography.caption))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _visible.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final lesson = _visible[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () async {
                                  await context.push('/admin/lessons/${lesson.id}/edit', extra: lesson.title);
                                  load();
                                },
                                child: PremiumCard(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFF3D6BE0).withValues(alpha: 0.12),
                                        child: Text(
                                          'L${lesson.orderNumber}',
                                          style: const TextStyle(
                                            color: Color(0xFF3D6BE0),
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
                                            Text(
                                              l10n.adminLessonMgmtLessonRowTitle(lesson.orderNumber, lesson.title),
                                              style: AppTypography.title,
                                            ),
                                            Text(
                                              '${lesson.courseTitle} › ${lesson.moduleTitle}',
                                              style: AppTypography.caption,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (lesson.hasQuiz)
                                        const Padding(
                                          padding: EdgeInsets.only(right: AppSpacing.xs),
                                          child: Icon(Icons.quiz, size: 18, color: AppColors.success),
                                        ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'edit':
                                              context.push('/admin/lessons/${lesson.id}/edit', extra: lesson.title);
                                            case 'move':
                                              moveLesson(lesson);
                                            case 'reorder':
                                              reorderLesson(lesson);
                                            case 'images':
                                              context.push(
                                                '/admin/lessons/${lesson.id}/images',
                                                extra: lesson.title,
                                              );
                                            case 'delete':
                                              deleteLesson(lesson);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(value: 'edit', child: Text(l10n.commonEdit)),
                                          PopupMenuItem(value: 'move', child: Text(l10n.adminMenuMoveToAnotherModule)),
                                          PopupMenuItem(value: 'reorder', child: Text(l10n.adminMenuChangePosition)),
                                          PopupMenuItem(value: 'images', child: Text(l10n.adminMenuManageImages)),
                                          const PopupMenuDivider(),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(l10n.commonDelete, style: const TextStyle(color: AppColors.error)),
                                          ),
                                        ],
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
      selectedColor: const Color(0xFF3D6BE0),
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
    );
  }
}
