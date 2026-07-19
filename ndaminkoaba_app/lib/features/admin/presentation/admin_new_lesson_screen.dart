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

class AdminNewLessonScreen extends StatefulWidget {
  const AdminNewLessonScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminNewLessonScreen> createState() => _AdminNewLessonScreenState();
}

class _AdminNewLessonScreenState extends State<AdminNewLessonScreen> {
  final repository = ContentRepository();
  final titleController = TextEditingController();
  final summaryController = TextEditingController();
  final contentController = TextEditingController();
  final frenchTitleController = TextEditingController();
  final frenchSummaryController = TextEditingController();
  final frenchContentController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  List<AdminCourseDetail> courses = [];
  AdminCourseDetail? selectedCourse;
  AdminModule? selectedModule;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    titleController.dispose();
    summaryController.dispose();
    contentController.dispose();
    frenchTitleController.dispose();
    frenchSummaryController.dispose();
    frenchContentController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getAllCourses(languageId: widget.languageId);
      if (!mounted) return;
      setState(() {
        courses = result;
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

  Future<void> submit() async {
    final module = selectedModule;
    if (module == null) return;

    if (titleController.text.trim().length < 3) {
      _showMessage('Title must be at least 3 characters.');
      return;
    }
    if (contentController.text.trim().length < 10) {
      _showMessage('Lesson content must be at least 10 characters.');
      return;
    }

    setState(() => isSaving = true);
    try {
      final lessonId = await repository.createLesson(
        moduleId: module.id,
        title: titleController.text.trim(),
        summary: summaryController.text.trim(),
        content: contentController.text.trim(),
        frenchTitle: frenchTitleController.text.trim(),
        frenchSummary: frenchSummaryController.text.trim(),
        frenchContent: frenchContentController.text.trim(),
        orderNumber: module.lessons.length + 1,
      );

      if (!mounted) return;
      _showMessage('Lesson created.');

      final addQuiz = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lesson created'),
          content: const Text('Add a quiz to it now so learners can complete it?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Later')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add Quiz')),
          ],
        ),
      );

      if (!mounted) return;
      if (addQuiz == true) {
        context.pushReplacement('/admin/lessons/$lessonId/quiz', extra: titleController.text.trim());
      } else {
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not create lesson.'));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'New Lesson'),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepBreadcrumb(
                      courseTitle: selectedCourse?.title,
                      moduleTitle: selectedModule?.title,
                      onResetCourse: () => setState(() {
                        selectedCourse = null;
                        selectedModule = null;
                      }),
                      onResetModule: () => setState(() => selectedModule = null),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (selectedCourse == null)
                      _CourseList(
                        courses: courses,
                        onSelect: (course) => setState(() => selectedCourse = course),
                      )
                    else if (selectedModule == null)
                      _ModuleList(
                        course: selectedCourse!,
                        onSelect: (module) => setState(() => selectedModule = module),
                      )
                    else
                      PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New lesson in "${selectedModule!.title}"', style: AppTypography.title),
                            const SizedBox(height: AppSpacing.lg),
                            PremiumTextField(label: 'Title', controller: titleController),
                            const SizedBox(height: AppSpacing.lg),
                            PremiumTextField(label: 'Summary', controller: summaryController),
                            const SizedBox(height: AppSpacing.lg),
                            Text('Content', style: AppTypography.caption),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: contentController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: 'The full lesson text learners will read...',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PremiumTextField(
                              label: 'French Title (optional)',
                              controller: frenchTitleController,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PremiumTextField(
                              label: 'French Summary (optional)',
                              controller: frenchSummaryController,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text('French Content (optional)', style: AppTypography.caption),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: frenchContentController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: 'The French translation of the lesson text...',
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            PrimaryButton(
                              label: 'Create Lesson',
                              isLoading: isSaving,
                              onPressed: submit,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StepBreadcrumb extends StatelessWidget {
  const _StepBreadcrumb({
    required this.courseTitle,
    required this.moduleTitle,
    required this.onResetCourse,
    required this.onResetModule,
  });

  final String? courseTitle;
  final String? moduleTitle;
  final VoidCallback onResetCourse;
  final VoidCallback onResetModule;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: onResetCourse,
          child: Text(
            'Course',
            style: AppTypography.title.copyWith(
              color: courseTitle == null ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
        if (courseTitle != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ),
          InkWell(
            onTap: onResetModule,
            child: Text(
              courseTitle!,
              style: AppTypography.title.copyWith(
                color: moduleTitle == null ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (moduleTitle != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ),
          Text(moduleTitle!, style: AppTypography.title.copyWith(color: AppColors.primary)),
        ],
      ],
    );
  }
}

class _CourseList extends StatelessWidget {
  const _CourseList({required this.courses, required this.onSelect});

  final List<AdminCourseDetail> courses;
  final ValueChanged<AdminCourseDetail> onSelect;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return PremiumCard(child: Text('No courses yet. Create one first.', style: AppTypography.caption));
    }

    return Column(
      children: courses
          .map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onSelect(course),
                child: PremiumCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.title, style: AppTypography.title),
                            Text('${course.modules.length} modules', style: AppTypography.caption),
                          ],
                        ),
                      ),
                      Chip(label: Text(course.level.replaceAll('_', ' '))),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ModuleList extends StatelessWidget {
  const _ModuleList({required this.course, required this.onSelect});

  final AdminCourseDetail course;
  final ValueChanged<AdminModule> onSelect;

  @override
  Widget build(BuildContext context) {
    if (course.modules.isEmpty) {
      return PremiumCard(
        child: Text(
          'This course has no modules yet — add one from the course editor first.',
          style: AppTypography.caption,
        ),
      );
    }

    return Column(
      children: course.modules
          .map(
            (module) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => onSelect(module),
                child: PremiumCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(module.title, style: AppTypography.title),
                            Text('${module.lessons.length} lessons', style: AppTypography.caption),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
