import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';
import '../domain/management_models.dart';
import 'widgets/move_lesson_dialog.dart';
import 'widgets/reorder_lesson_dialog.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

class AdminCourseEditorScreen extends StatefulWidget {
  const AdminCourseEditorScreen({super.key, this.courseId, required this.languageId, this.languageName});

  /// Null means "create a new course".
  final String? courseId;
  final String languageId;
  final String? languageName;

  @override
  State<AdminCourseEditorScreen> createState() => _AdminCourseEditorScreenState();
}

class _AdminCourseEditorScreenState extends State<AdminCourseEditorScreen> {
  final repository = ContentRepository();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final frenchTitleController = TextEditingController();
  final frenchDescriptionController = TextEditingController();
  final hoursController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  String level = 'BEGINNER';
  List<ManagedModule> allModules = [];
  AdminCourseDetail? course;
  String? savedCourseId;

  bool get isNew => widget.courseId == null && savedCourseId == null;
  String? get effectiveCourseId => widget.courseId ?? savedCourseId;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    frenchTitleController.dispose();
    frenchDescriptionController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final fetchedModules = await repository.getAllModulesFlat();
      AdminCourseDetail? fetchedCourse;

      if (effectiveCourseId != null) {
        fetchedCourse = await repository.getCourse(effectiveCourseId!);
      }

      if (!mounted) return;
      setState(() {
        allModules = fetchedModules;
        course = fetchedCourse;
        if (fetchedCourse != null) {
          titleController.text = fetchedCourse.title;
          descriptionController.text = fetchedCourse.description;
          frenchTitleController.text = fetchedCourse.frenchTitle ?? '';
          frenchDescriptionController.text = fetchedCourse.frenchDescription ?? '';
          hoursController.text = fetchedCourse.estimatedHours?.toString() ?? '';
          level = fetchedCourse.level.isNotEmpty ? fetchedCourse.level : 'BEGINNER';
        }
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> saveCourse() async {
    if (titleController.text.trim().length < 3) {
      _showMessage('Title must be at least 3 characters.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final hours = int.tryParse(hoursController.text.trim());

      if (isNew) {
        final id = await repository.createCourse(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          frenchTitle: frenchTitleController.text.trim(),
          frenchDescription: frenchDescriptionController.text.trim(),
          level: level,
          languageId: widget.languageId,
          estimatedHours: hours,
        );
        if (!mounted) return;
        setState(() => savedCourseId = id);
        await load();
        _showMessage('Course created. Now add modules and lessons below.');
      } else {
        await repository.updateCourse(
          effectiveCourseId!,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          frenchTitle: frenchTitleController.text.trim(),
          frenchDescription: frenchDescriptionController.text.trim(),
          level: level,
          estimatedHours: hours,
        );
        await load();
        _showMessage('Course updated.');
      }
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not save course.'));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addModule() async {
    final result = await _showFormDialog(
      title: 'Add Module',
      fields: const ['Title', 'Description', 'French Title', 'French Description'],
    );
    if (result == null) return;

    try {
      await repository.createModule(
        courseId: effectiveCourseId!,
        title: result['Title']!.trim(),
        description: result['Description']!.trim(),
        frenchTitle: result['French Title']!.trim(),
        frenchDescription: result['French Description']!.trim(),
        orderNumber: (course?.modules.length ?? 0) + 1,
      );
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add module.'));
    }
  }

  Future<void> _renameModule(AdminModule module) async {
    final result = await _showFormDialog(
      title: 'Rename Module',
      fields: const ['Title', 'Description', 'French Title', 'French Description'],
      initialValues: {
        'Title': module.title,
        'Description': module.description,
        'French Title': module.frenchTitle ?? '',
        'French Description': module.frenchDescription ?? '',
      },
      submitLabel: 'Save',
    );
    if (result == null) return;
    if (result['Title']!.trim().length < 3) {
      _showMessage('Title must be at least 3 characters.');
      return;
    }

    try {
      await repository.updateModule(
        module.id,
        title: result['Title']!.trim(),
        description: result['Description']!.trim(),
        frenchTitle: result['French Title']!.trim(),
        frenchDescription: result['French Description']!.trim(),
      );
      await load();
      _showMessage('Module updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update module.'));
    }
  }

  Future<void> _moveLesson(AdminLesson lesson) async {
    final result = await showMoveLessonDialog(
      context: context,
      modules: allModules,
      currentModuleId: lesson.moduleId,
    );
    if (result == null) return;

    try {
      await repository.updateLesson(
        lesson.id,
        moduleId: result.moduleId,
        orderNumber: result.orderNumber,
      );
      await load();
      _showMessage('Lesson moved.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not move lesson.'));
    }
  }

  Future<void> _reorderLesson(AdminModule module, AdminLesson lesson) async {
    final currentIndex = module.lessons.indexWhere((l) => l.id == lesson.id);

    final newPosition = await showReorderLessonDialog(
      context: context,
      currentPosition: currentIndex + 1,
      totalLessons: module.lessons.length,
    );
    if (newPosition == null) return;
    final toIndex = newPosition - 1;
    if (toIndex == currentIndex) return;

    final changes = reorderLessonPositions(
      lessons: module.lessons.map((l) => (id: l.id, orderNumber: l.orderNumber)).toList(),
      fromIndex: currentIndex,
      toIndex: toIndex,
    );

    try {
      for (final entry in changes.entries) {
        await repository.updateLesson(entry.key, orderNumber: entry.value);
      }
      await load();
      _showMessage('Lesson reordered.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not reorder lesson.'));
    }
  }

  Future<void> _deleteModule(AdminModule module) async {
    if (module.lessons.isNotEmpty) {
      _showMessage('Delete this module\'s lessons first.');
      return;
    }
    try {
      await repository.deleteModule(module.id);
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete module.'));
    }
  }

  Future<void> _addLesson(AdminModule module) async {
    final result = await _showFormDialog(
      title: 'Add Lesson to "${module.title}"',
      fields: const [
        'Title',
        'Summary',
        'Content',
        'French Title',
        'French Summary',
        'French Content',
      ],
      multilineFields: const ['Content', 'French Content'],
    );
    if (result == null) return;

    if (result['Content']!.trim().length < 10) {
      _showMessage('Lesson content must be at least 10 characters.');
      return;
    }

    try {
      await repository.createLesson(
        moduleId: module.id,
        title: result['Title']!.trim(),
        summary: result['Summary']!.trim(),
        content: result['Content']!.trim(),
        frenchTitle: result['French Title']!.trim(),
        frenchSummary: result['French Summary']!.trim(),
        frenchContent: result['French Content']!.trim(),
        orderNumber: module.lessons.length + 1,
      );
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add lesson.'));
    }
  }

  Future<void> _deleteLesson(AdminLesson lesson) async {
    try {
      await repository.deleteLesson(lesson.id);
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete lesson.'));
    }
  }

  Future<void> _editLesson(AdminLesson lesson) async {
    final result = await _showFormDialog(
      title: 'Edit "${lesson.title}"',
      fields: const [
        'Title',
        'Summary',
        'Content',
        'French Title',
        'French Summary',
        'French Content',
      ],
      multilineFields: const ['Content', 'French Content'],
      initialValues: {
        'Title': lesson.title,
        'Summary': lesson.summary,
        'Content': lesson.content,
        'French Title': lesson.frenchTitle ?? '',
        'French Summary': lesson.frenchSummary ?? '',
        'French Content': lesson.frenchContent ?? '',
      },
      submitLabel: 'Save',
    );
    if (result == null) return;

    if (result['Content']!.trim().length < 10) {
      _showMessage('Lesson content must be at least 10 characters.');
      return;
    }

    try {
      await repository.updateLesson(
        lesson.id,
        title: result['Title']!.trim(),
        summary: result['Summary']!.trim(),
        content: result['Content']!.trim(),
        frenchTitle: result['French Title']!.trim(),
        frenchSummary: result['French Summary']!.trim(),
        frenchContent: result['French Content']!.trim(),
      );
      await load();
      _showMessage('Lesson updated.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not update lesson.'));
    }
  }

  Future<Map<String, String>?> _showFormDialog({
    required String title,
    required List<String> fields,
    List<String> multilineFields = const [],
    Map<String, String> initialValues = const {},
    String submitLabel = 'Add',
  }) {
    final controllers = {
      for (final f in fields) f: TextEditingController(text: initialValues[f]),
    };

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: TextField(
                      controller: controllers[f],
                      maxLines: multilineFields.contains(f) ? 5 : 1,
                      decoration: InputDecoration(labelText: f),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              {for (final f in fields) f: controllers[f]!.text},
            ),
            child: Text(submitLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: isNew ? 'New Course' : 'Edit Course',
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Course Details', style: AppTypography.title),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: 'Title',
                            controller: titleController,
                            prefixIcon: Icons.title,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: 'Description',
                            controller: descriptionController,
                            prefixIcon: Icons.notes,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: 'French Title (optional)',
                            controller: frenchTitleController,
                            prefixIcon: Icons.title,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: 'French Description (optional)',
                            controller: frenchDescriptionController,
                            prefixIcon: Icons.notes,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Level', style: AppTypography.caption),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: _levels
                                .map(
                                  (l) => ChoiceChip(
                                    label: Text(l),
                                    selected: level == l,
                                    onSelected: (_) => setState(() => level = l),
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: level == l ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Language', style: AppTypography.caption),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(Icons.language, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                widget.languageName ?? 'This language',
                                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PremiumTextField(
                            label: 'Estimated Hours',
                            controller: hoursController,
                            prefixIcon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          PrimaryButton(
                            label: isNew ? 'Create Course' : 'Save Changes',
                            isLoading: isSaving,
                            onPressed: saveCourse,
                          ),
                        ],
                      ),
                    ),
                    if (effectiveCourseId != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Modules & Lessons',
                              style: AppTypography.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addModule,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Module'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (course == null || course!.modules.isEmpty)
                        PremiumCard(
                          child: Text(
                            'No modules yet. Add one to start adding lessons.',
                            style: AppTypography.caption,
                          ),
                        )
                      else
                        ...course!.modules.map(
                          (module) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: PremiumCard(
                              padding: EdgeInsets.zero,
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  title: Text(
                                    module.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.title,
                                  ),
                                  subtitle: Text('${module.lessons.length} lessons'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Rename module',
                                        onPressed: () => _renameModule(module),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        tooltip: 'Delete module',
                                        onPressed: () => _deleteModule(module),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    ...module.lessons.map(
                                      (lesson) => ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                          child: Text(
                                            '${lesson.orderNumber}',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          lesson.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.title.copyWith(fontSize: 15),
                                        ),
                                        subtitle: Text(
                                          lesson.summary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'edit':
                                                _editLesson(lesson);
                                              case 'move':
                                                _moveLesson(lesson);
                                              case 'reorder':
                                                _reorderLesson(module, lesson);
                                              case 'images':
                                                context.push(
                                                  '/admin/lessons/${lesson.id}/images',
                                                  extra: lesson.title,
                                                );
                                              case 'quiz':
                                                context.push(
                                                  '/admin/lessons/${lesson.id}/quiz',
                                                  extra: lesson.title,
                                                );
                                              case 'delete':
                                                _deleteLesson(lesson);
                                            }
                                          },
                                          itemBuilder: (context) => const [
                                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                                            PopupMenuItem(value: 'move', child: Text('Move to another module')),
                                            PopupMenuItem(value: 'reorder', child: Text('Change position')),
                                            PopupMenuItem(value: 'images', child: Text('Manage images')),
                                            PopupMenuItem(value: 'quiz', child: Text('Manage quiz')),
                                            PopupMenuDivider(),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete', style: TextStyle(color: AppColors.error)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton.icon(
                                          onPressed: () => _addLesson(module),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add Lesson'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
