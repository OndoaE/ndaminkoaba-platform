import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/content_repository.dart';
import '../domain/management_models.dart';
import 'widgets/move_lesson_dialog.dart';
import 'widgets/reorder_lesson_dialog.dart';

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
    final titleController = TextEditingController(text: lesson.title);
    final summaryController = TextEditingController(text: lesson.summary);
    final contentController = TextEditingController(text: lesson.content);
    final frenchTitleController = TextEditingController(text: lesson.frenchTitle ?? '');
    final frenchSummaryController = TextEditingController(text: lesson.frenchSummary ?? '');
    final frenchContentController = TextEditingController(text: lesson.frenchContent ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit "${lesson.title}"'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: AppSpacing.md),
              TextField(controller: summaryController, decoration: const InputDecoration(labelText: 'Summary')),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchTitleController,
                decoration: const InputDecoration(labelText: 'French Title (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchSummaryController,
                decoration: const InputDecoration(labelText: 'French Summary (optional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: frenchContentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'French Content (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (confirmed != true) return;

    if (contentController.text.trim().length < 10) {
      _showMessage('Lesson content must be at least 10 characters.');
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
      );
      load();
      _showMessage('Lesson updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update lesson.'));
    }
  }

  Future<void> moveLesson(ManagedLesson lesson) async {
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
      _showMessage('Lesson moved.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not move lesson.'));
    }
  }

  List<ManagedLesson> _siblings(ManagedLesson lesson) =>
      lessons.where((l) => l.moduleId == lesson.moduleId).toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

  Future<void> reorderLesson(ManagedLesson lesson) async {
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
      _showMessage('Lesson reordered.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not reorder lesson.'));
    }
  }

  Future<void> deleteLesson(ManagedLesson lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: Text(
          lesson.hasQuiz
              ? 'Delete "${lesson.title}"? Its quiz must be deleted first (from Quiz Management).'
              : 'Delete "${lesson.title}"?',
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
      await contentRepository.deleteLesson(lesson.id);
      load();
      _showMessage('Lesson deleted.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete lesson.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Lesson Management', colors: [Color(0xFF3D6BE0), AppColors.primary]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3D6BE0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Lesson', style: TextStyle(color: Colors.white)),
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
                  hintText: 'Search lessons...',
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
                        label: 'All Courses',
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
                        ? Center(child: Text('No lessons found.', style: AppTypography.caption))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _visible.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final lesson = _visible[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => editLesson(lesson),
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
                                              'Lesson ${lesson.orderNumber}: ${lesson.title}',
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
                                              editLesson(lesson);
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
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                                          PopupMenuItem(value: 'move', child: Text('Move to another module')),
                                          PopupMenuItem(value: 'reorder', child: Text('Change position')),
                                          PopupMenuItem(value: 'images', child: Text('Manage images')),
                                          PopupMenuDivider(),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete', style: TextStyle(color: AppColors.error)),
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
