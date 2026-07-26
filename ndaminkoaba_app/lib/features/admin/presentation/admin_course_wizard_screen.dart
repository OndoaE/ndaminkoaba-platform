import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../config/app_config.dart';
import '../../../core/network/api_error.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/progress_ring.dart';
import '../../../design_system/widgets/status_pill.dart';
import '../../../design_system/widgets/wizard_stepper.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';
import '../domain/admin_models.dart';
import '../domain/management_models.dart';
import 'widgets/move_lesson_dialog.dart';
import 'widgets/reorder_lesson_dialog.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

List<String> _wizardSteps(AppLocalizations l10n) => [
      l10n.adminWizardStepDetails,
      l10n.adminWizardStepCurriculum,
      l10n.adminWizardStepResources,
      l10n.adminWizardStepAssessment,
      l10n.adminWizardStepReview,
    ];

String _levelLabel(AppLocalizations l10n, String level) {
  return switch (level) {
    'BEGINNER' => l10n.adminLevelBeginner,
    'INTERMEDIATE' => l10n.adminLevelIntermediate,
    'ADVANCED' => l10n.adminLevelAdvanced,
    _ => level,
  };
}

// Internal field keys (used as map lookups) with their localized display
// labels — kept separate from the label text so the dialog can stay
// English-keyed internally while displaying translated labels.
Map<String, String> _moduleFieldLabels(AppLocalizations l10n) => {
      'Title': l10n.adminFieldTitle,
      'Description': l10n.adminFieldDescription,
      'French Title': l10n.adminFieldFrenchTitle,
      'French Description': l10n.adminFieldFrenchDescription,
    };

Map<String, String> _lessonFieldLabels(AppLocalizations l10n) => {
      'Title': l10n.adminFieldTitle,
      'Summary': l10n.adminFieldSummary,
      'Content': l10n.adminFieldContent,
      'French Title': l10n.adminFieldFrenchTitle,
      'French Summary': l10n.adminFieldFrenchSummary,
      'French Content': l10n.adminFieldFrenchContent,
    };

/// Desktop 5-step Create/Edit Course flow — replaces the old single-page
/// [AdminCourseEditorScreen]. A persistent right sidebar (cover, publishing
/// settings, course team, content readiness, danger zone) only appears once
/// the course itself exists (i.e. after step 1 is saved), since every
/// sidebar action writes to the course record.
class AdminCourseWizardScreen extends StatefulWidget {
  const AdminCourseWizardScreen({super.key, this.courseId, required this.languageId, this.languageName});

  /// Null means "create a new course".
  final String? courseId;
  final String languageId;
  final String? languageName;

  @override
  State<AdminCourseWizardScreen> createState() => _AdminCourseWizardScreenState();
}

class _AdminCourseWizardScreenState extends State<AdminCourseWizardScreen> {
  final repository = ContentRepository();
  final adminRepository = AdminRepository();
  final picker = ImagePicker();

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final frenchTitleController = TextEditingController();
  final frenchDescriptionController = TextEditingController();
  final hoursController = TextEditingController();
  final categoryController = TextEditingController();
  final tagInputController = TextEditingController();
  final objectiveInputController = TextEditingController();
  final supportLanguageInputController = TextEditingController();

  int stepIndex = 0;
  bool isLoading = true;
  bool isSaving = false;
  bool isUploadingCover = false;

  String level = 'BEGINNER';
  List<String> tags = [];
  List<String> objectives = [];
  List<String> supportLanguageCodes = [];
  String? thumbnailUrl;
  String visibility = 'PUBLIC';
  String enrollmentMode = 'OPEN';
  bool issueCertificate = true;
  DateTime? publicationDate;
  String? teacherId;
  String? reviewerId;
  String? prerequisiteCourseId;

  List<ManagedModule> allModules = [];
  List<AdminCourseDetail> languageCourses = [];
  List<AdminUser> staff = [];
  AdminCourseDetail? course;
  String? savedCourseId;
  ({int completionPercent, bool courseDetailsComplete, int lessonsReadyCount, int lessonsTotalCount, int lessonsMissingAudioCount, bool assessmentComplete})?
      readiness;

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
    subtitleController.dispose();
    descriptionController.dispose();
    frenchTitleController.dispose();
    frenchDescriptionController.dispose();
    hoursController.dispose();
    categoryController.dispose();
    tagInputController.dispose();
    objectiveInputController.dispose();
    supportLanguageInputController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final futures = <Future>[
        repository.getAllModulesFlat(),
        adminRepository.getUsers(),
        repository.getAllCourses(languageId: widget.languageId),
      ];
      if (effectiveCourseId != null) {
        futures.add(repository.getCourse(effectiveCourseId!));
        futures.add(repository.getCourseReadiness(effectiveCourseId!));
      }
      final results = await Future.wait(futures);

      if (!mounted) return;
      setState(() {
        allModules = results[0] as List<ManagedModule>;
        staff = (results[1] as List<AdminUser>)
            .where((u) => u.role == 'TEACHER' || u.role == 'ADMIN')
            .toList();
        languageCourses = (results[2] as List<AdminCourseDetail>)
            .where((c) => c.id != effectiveCourseId)
            .toList();

        if (effectiveCourseId != null) {
          final fetchedCourse = results[3] as AdminCourseDetail;
          course = fetchedCourse;
          readiness = results[4]
              as ({
                int completionPercent,
                bool courseDetailsComplete,
                int lessonsReadyCount,
                int lessonsTotalCount,
                int lessonsMissingAudioCount,
                bool assessmentComplete
              });

          titleController.text = fetchedCourse.title;
          subtitleController.text = fetchedCourse.subtitle;
          descriptionController.text = fetchedCourse.description;
          frenchTitleController.text = fetchedCourse.frenchTitle ?? '';
          frenchDescriptionController.text = fetchedCourse.frenchDescription ?? '';
          hoursController.text = fetchedCourse.estimatedHours?.toString() ?? '';
          categoryController.text = fetchedCourse.category;
          level = fetchedCourse.level.isNotEmpty ? fetchedCourse.level : 'BEGINNER';
          tags = List.of(fetchedCourse.tags);
          objectives = List.of(fetchedCourse.learningObjectives);
          supportLanguageCodes = List.of(fetchedCourse.supportLanguageCodes);
          thumbnailUrl = fetchedCourse.thumbnailUrl;
          visibility = fetchedCourse.visibility;
          enrollmentMode = fetchedCourse.enrollmentMode;
          issueCertificate = fetchedCourse.issueCertificate;
          publicationDate = fetchedCourse.publicationDate;
          teacherId = fetchedCourse.teacherId;
          reviewerId = fetchedCourse.reviewerId;
          prerequisiteCourseId = fetchedCourse.prerequisiteCourseId;
        }
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

  Future<bool> _saveCourseDetails() async {
    final l10n = AppLocalizations.of(context);
    if (titleController.text.trim().length < 3) {
      _showMessage(l10n.adminTitleMinLengthError);
      return false;
    }

    setState(() => isSaving = true);
    try {
      final hours = int.tryParse(hoursController.text.trim());
      if (isNew) {
        final id = await repository.createCourse(
          title: titleController.text.trim(),
          subtitle: subtitleController.text.trim(),
          description: descriptionController.text.trim(),
          frenchTitle: frenchTitleController.text.trim(),
          frenchDescription: frenchDescriptionController.text.trim(),
          level: level,
          languageId: widget.languageId,
          estimatedHours: hours,
          category: categoryController.text.trim(),
          tags: tags,
          learningObjectives: objectives,
        );
        if (!mounted) return false;
        setState(() => savedCourseId = id);
        await load();
        _showMessage(l10n.adminCourseCreatedMessage);
      } else {
        await repository.updateCourse(
          effectiveCourseId!,
          title: titleController.text.trim(),
          subtitle: subtitleController.text.trim(),
          description: descriptionController.text.trim(),
          frenchTitle: frenchTitleController.text.trim(),
          frenchDescription: frenchDescriptionController.text.trim(),
          level: level,
          estimatedHours: hours,
          category: categoryController.text.trim(),
          tags: tags,
          learningObjectives: objectives,
        );
        await load();
      }
      return true;
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotSaveCourse));
      return false;
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _saveLearningResources() async {
    if (effectiveCourseId == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      await repository.updateCourse(
        effectiveCourseId!,
        supportLanguageCodes: supportLanguageCodes,
        prerequisiteCourseId: prerequisiteCourseId ?? '',
      );
      _showMessage(l10n.adminLearningResourcesSavedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotSaveGeneric));
    }
  }

  Future<void> _autoSaveSidebar(Map<String, dynamic> fields) async {
    if (effectiveCourseId == null) return;
    try {
      await repository.updateCourse(
        effectiveCourseId!,
        visibility: fields['visibility'],
        enrollmentMode: fields['enrollmentMode'],
        issueCertificate: fields['issueCertificate'],
        teacherId: fields['teacherId'],
        reviewerId: fields['reviewerId'],
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotSaveGeneric));
    }
  }

  Future<void> _uploadCover() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || effectiveCourseId == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);

    setState(() => isUploadingCover = true);
    try {
      final url = await repository.uploadImage(bytes, picked.name);
      await repository.updateCourse(effectiveCourseId!, thumbnailUrl: url);
      if (!mounted) return;
      setState(() => thumbnailUrl = url);
      _showMessage(l10n.adminCoverUpdatedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotUploadCover));
    } finally {
      if (mounted) setState(() => isUploadingCover = false);
    }
  }

  Future<void> _archiveCourse() async {
    if (effectiveCourseId == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminArchiveCourseTitle),
        content: Text(l10n.adminArchiveCourseConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.adminBulkArchive),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await repository.updateCourse(effectiveCourseId!, status: 'ARCHIVED');
      await load();
      _showMessage(l10n.adminCourseArchivedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotArchiveCourse));
    }
  }

  Future<void> _publish() async {
    if (effectiveCourseId == null) return;
    final l10n = AppLocalizations.of(context);
    try {
      await repository.updateCourse(
        effectiveCourseId!,
        status: 'PUBLISHED',
        publicationDate: publicationDate?.toIso8601String(),
      );
      await load();
      _showMessage(l10n.adminCoursePublishedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotPublishCourse));
    }
  }

  Future<void> _goNext() async {
    if (stepIndex == 0) {
      final ok = await _saveCourseDetails();
      if (!ok) return;
    } else if (stepIndex == 2) {
      await _saveLearningResources();
    }
    if (!mounted) return;
    if (stepIndex < _wizardSteps(AppLocalizations.of(context)).length - 1) {
      setState(() => stepIndex++);
    }
  }

  // --- Curriculum (module/lesson) CRUD — same dialogs/logic as the old
  // single-page editor, now embedded as wizard step 2. ---

  Future<void> _addModule() async {
    final l10n = AppLocalizations.of(context);
    final result = await _showFormDialog(
      title: l10n.adminAddModuleTitle,
      fields: const ['Title', 'Description', 'French Title', 'French Description'],
      fieldLabels: _moduleFieldLabels(l10n),
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
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotAddModule));
    }
  }

  Future<void> _renameModule(AdminModule module) async {
    final l10n = AppLocalizations.of(context);
    final result = await _showFormDialog(
      title: l10n.adminRenameModuleTitle,
      fields: const ['Title', 'Description', 'French Title', 'French Description'],
      fieldLabels: _moduleFieldLabels(l10n),
      initialValues: {
        'Title': module.title,
        'Description': module.description,
        'French Title': module.frenchTitle ?? '',
        'French Description': module.frenchDescription ?? '',
      },
      submitLabel: l10n.commonSave,
    );
    if (result == null) return;
    try {
      await repository.updateModule(
        module.id,
        title: result['Title']!.trim(),
        description: result['Description']!.trim(),
        frenchTitle: result['French Title']!.trim(),
        frenchDescription: result['French Description']!.trim(),
      );
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotUpdateModule));
    }
  }

  Future<void> _deleteModule(AdminModule module) async {
    final l10n = AppLocalizations.of(context);
    if (module.lessons.isNotEmpty) {
      _showMessage(l10n.adminModuleLessonsFirstError);
      return;
    }
    try {
      await repository.deleteModule(module.id);
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotDeleteModule));
    }
  }

  Future<void> _addLesson(AdminModule module) async {
    final l10n = AppLocalizations.of(context);
    final result = await _showFormDialog(
      title: l10n.adminAddLessonToTitle(module.title),
      fields: const ['Title', 'Summary', 'Content', 'French Title', 'French Summary', 'French Content'],
      fieldLabels: _lessonFieldLabels(l10n),
      multilineFields: const ['Content', 'French Content'],
    );
    if (result == null) return;
    if (result['Content']!.trim().length < 10) {
      _showMessage(l10n.adminLessonContentMinLengthError);
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
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotAddLesson));
    }
  }

  Future<void> _editLesson(AdminLesson lesson) async {
    final l10n = AppLocalizations.of(context);
    final result = await _showFormDialog(
      title: l10n.adminEditLessonTitle(lesson.title),
      fields: const ['Title', 'Summary', 'Content', 'French Title', 'French Summary', 'French Content'],
      fieldLabels: _lessonFieldLabels(l10n),
      multilineFields: const ['Content', 'French Content'],
      initialValues: {
        'Title': lesson.title,
        'Summary': lesson.summary,
        'Content': lesson.content,
        'French Title': lesson.frenchTitle ?? '',
        'French Summary': lesson.frenchSummary ?? '',
        'French Content': lesson.frenchContent ?? '',
      },
      submitLabel: l10n.commonSave,
    );
    if (result == null) return;
    if (result['Content']!.trim().length < 10) {
      _showMessage(l10n.adminLessonContentMinLengthError);
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
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotUpdateLesson));
    }
  }

  Future<void> _deleteLesson(AdminLesson lesson) async {
    final l10n = AppLocalizations.of(context);
    try {
      await repository.deleteLesson(lesson.id);
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotDeleteLesson));
    }
  }

  Future<void> _moveLesson(AdminLesson lesson) async {
    final l10n = AppLocalizations.of(context);
    final result = await showMoveLessonDialog(
      context: context,
      modules: allModules,
      currentModuleId: lesson.moduleId,
    );
    if (result == null) return;
    try {
      await repository.updateLesson(lesson.id, moduleId: result.moduleId, orderNumber: result.orderNumber);
      await load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotMoveLesson));
    }
  }

  Future<void> _reorderLesson(AdminModule module, AdminLesson lesson) async {
    final l10n = AppLocalizations.of(context);
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
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotReorderLesson));
    }
  }

  Future<Map<String, String>?> _showFormDialog({
    required String title,
    required List<String> fields,
    required Map<String, String> fieldLabels,
    List<String> multilineFields = const [],
    Map<String, String> initialValues = const {},
    String? submitLabel,
  }) {
    final l10n = AppLocalizations.of(context);
    final controllers = {for (final f in fields) f: TextEditingController(text: initialValues[f])};
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields
                .map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextField(
                        controller: controllers[f],
                        maxLines: multilineFields.contains(f) ? 5 : 1,
                        decoration: InputDecoration(labelText: fieldLabels[f] ?? f),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, {for (final f in fields) f: controllers[f]!.text}),
            child: Text(submitLabel ?? l10n.commonAdd),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.languageName ?? l10n.adminLanguageFallback;
    final steps = _wizardSteps(l10n);

    return AdminShell(
      activeNavKey: 'courses',
      languageId: widget.languageId,
      languageName: title,
      title: isNew ? l10n.adminCreateCourseTitle : l10n.adminEditCourseTitle,
      subtitle: isNew ? l10n.adminBuildNewCourseSubtitle(title) : titleController.text,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
                  child: WizardStepper(steps: steps, currentStep: stepIndex),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildStepBody()),
                    if (effectiveCourseId != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(width: 280, child: _buildSidebar()),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    if (stepIndex > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => stepIndex--),
                        child: Text(l10n.adminBackButton),
                      ),
                    const Spacer(),
                    if (stepIndex < steps.length - 1)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: isSaving ? null : _goNext,
                        child: Text(isSaving ? l10n.adminSavingLabel : (stepIndex == 0 && isNew ? l10n.adminCreateAndContinueButton : l10n.adminNextButton)),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStepBody() {
    switch (stepIndex) {
      case 0:
        return _CourseDetailsStep(
          titleController: titleController,
          subtitleController: subtitleController,
          descriptionController: descriptionController,
          frenchTitleController: frenchTitleController,
          frenchDescriptionController: frenchDescriptionController,
          hoursController: hoursController,
          categoryController: categoryController,
          tagInputController: tagInputController,
          objectiveInputController: objectiveInputController,
          level: level,
          onLevelChanged: (l) => setState(() => level = l),
          tags: tags,
          onAddTag: (t) => setState(() => tags.add(t)),
          onRemoveTag: (t) => setState(() => tags.remove(t)),
          objectives: objectives,
          onAddObjective: (o) => setState(() => objectives.add(o)),
          onRemoveObjective: (o) => setState(() => objectives.remove(o)),
          languageName: widget.languageName ?? AppLocalizations.of(context).adminThisLanguageFallback,
        );
      case 1:
        return _CurriculumStep(
          course: course,
          onAddModule: _addModule,
          onRenameModule: _renameModule,
          onDeleteModule: _deleteModule,
          onAddLesson: _addLesson,
          onEditLesson: _editLesson,
          onDeleteLesson: _deleteLesson,
          onMoveLesson: _moveLesson,
          onReorderLesson: _reorderLesson,
        );
      case 2:
        return _LearningResourcesStep(
          supportLanguageInputController: supportLanguageInputController,
          supportLanguageCodes: supportLanguageCodes,
          onAddSupportLanguage: (c) => setState(() => supportLanguageCodes.add(c)),
          onRemoveSupportLanguage: (c) => setState(() => supportLanguageCodes.remove(c)),
          prerequisiteCourseId: prerequisiteCourseId,
          languageCourses: languageCourses,
          onPrerequisiteChanged: (id) => setState(() => prerequisiteCourseId = id),
        );
      case 3:
        return _AssessmentStep(course: course, languageId: widget.languageId, languageName: widget.languageName);
      case 4:
      default:
        return _ReviewPublishStep(
          course: course,
          readiness: readiness,
          publicationDate: publicationDate,
          onPublicationDateChanged: (d) => setState(() => publicationDate = d),
          onPublish: _publish,
        );
    }
  }

  Widget _buildSidebar() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SidebarCard(
          title: l10n.adminCourseCoverTitle,
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: AppRadius.small),
                  clipBehavior: Clip.antiAlias,
                  child: thumbnailUrl == null
                      ? const Center(child: Icon(Icons.image_outlined, color: AppColors.textSecondary))
                      : Image.network('${AppConfig.origin}$thumbnailUrl', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: isUploadingCover ? null : _uploadCover,
                icon: const Icon(Icons.upload, size: 16),
                label: Text(isUploadingCover ? l10n.adminUploadingLabel : l10n.adminUploadCoverButton),
              ),
              const SizedBox(height: AppSpacing.xs),
              Tooltip(
                message: l10n.adminGenerateWithAiTooltip,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(l10n.adminGenerateWithAiButton),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SidebarCard(
          title: l10n.adminPublishingSettingsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labeledDropdown(
                l10n.adminVisibilityLabel,
                visibility,
                {'PUBLIC': l10n.adminVisibilityPublic, 'PRIVATE': l10n.adminVisibilityPrivate},
                (v) {
                  setState(() => visibility = v);
                  _autoSaveSidebar({'visibility': v});
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _labeledDropdown(
                l10n.adminEnrollmentLabel,
                enrollmentMode,
                {'OPEN': l10n.adminEnrollmentOpen, 'INVITE_ONLY': l10n.adminEnrollmentInviteOnly},
                (v) {
                  setState(() => enrollmentMode = v);
                  _autoSaveSidebar({'enrollmentMode': v});
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: Text(l10n.adminIssueCertificateLabel, style: AppTypography.caption)),
                  Switch(
                    value: issueCertificate,
                    onChanged: (v) {
                      setState(() => issueCertificate = v);
                      _autoSaveSidebar({'issueCertificate': v});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SidebarCard(
          title: l10n.adminCourseTeamTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.adminInstructorLabel, style: AppTypography.caption),
              const SizedBox(height: 4),
              DropdownButton<String?>(
                isExpanded: true,
                value: teacherId,
                hint: Text(l10n.commonUnassigned),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.commonUnassigned)),
                  for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.fullName, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) {
                  setState(() => teacherId = v);
                  _autoSaveSidebar({'teacherId': v ?? ''});
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.adminColReviewer, style: AppTypography.caption),
              const SizedBox(height: 4),
              DropdownButton<String?>(
                isExpanded: true,
                value: reviewerId,
                hint: Text(l10n.commonUnassigned),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.commonUnassigned)),
                  for (final s in staff) DropdownMenuItem(value: s.id, child: Text(s.fullName, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) {
                  setState(() => reviewerId = v);
                  _autoSaveSidebar({'reviewerId': v ?? ''});
                },
              ),
            ],
          ),
        ),
        if (readiness != null) ...[
          const SizedBox(height: AppSpacing.md),
          _SidebarCard(
            title: l10n.adminContentReadinessTitle,
            child: Center(
              child: ProgressRing(
                progress: readiness!.completionPercent / 100,
                centerLabel: '${readiness!.completionPercent}%',
                subLabel: l10n.adminReadyLabel,
                size: 100,
              ),
            ),
          ),
        ],
        if (widget.courseId != null) ...[
          const SizedBox(height: AppSpacing.md),
          _SidebarCard(
            title: l10n.adminDangerZoneTitle,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              onPressed: _archiveCourse,
              icon: const Icon(Icons.archive_outlined, size: 16),
              label: Text(l10n.adminArchiveCourseButton),
            ),
          ),
        ],
      ],
    );
  }

  Widget _labeledDropdown(String label, String value, Map<String, String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 4),
        DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: [for (final e in options.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

class _SidebarCard extends StatelessWidget {
  const _SidebarCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.title.copyWith(fontSize: 14)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: child,
    );
  }
}

class _CourseDetailsStep extends StatelessWidget {
  const _CourseDetailsStep({
    required this.titleController,
    required this.subtitleController,
    required this.descriptionController,
    required this.frenchTitleController,
    required this.frenchDescriptionController,
    required this.hoursController,
    required this.categoryController,
    required this.tagInputController,
    required this.objectiveInputController,
    required this.level,
    required this.onLevelChanged,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.objectives,
    required this.onAddObjective,
    required this.onRemoveObjective,
    required this.languageName,
  });

  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final TextEditingController descriptionController;
  final TextEditingController frenchTitleController;
  final TextEditingController frenchDescriptionController;
  final TextEditingController hoursController;
  final TextEditingController categoryController;
  final TextEditingController tagInputController;
  final TextEditingController objectiveInputController;
  final String level;
  final ValueChanged<String> onLevelChanged;
  final List<String> tags;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;
  final List<String> objectives;
  final ValueChanged<String> onAddObjective;
  final ValueChanged<String> onRemoveObjective;
  final String languageName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminWizardStepDetails, style: AppTypography.title),
          const SizedBox(height: AppSpacing.lg),
          TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.adminFieldTitle)),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: subtitleController, decoration: InputDecoration(labelText: l10n.adminSubtitleOptionalLabel)),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: descriptionController, maxLines: 3, decoration: InputDecoration(labelText: l10n.adminFieldDescription)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: TextField(controller: frenchTitleController, decoration: InputDecoration(labelText: l10n.adminFrenchTitleOptionalLabel))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: TextField(controller: categoryController, decoration: InputDecoration(labelText: l10n.adminCategoryOptionalLabel))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: frenchDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.adminFrenchDescriptionOptionalLabel),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminColLevel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _levels
                .map((l) => ChoiceChip(
                      label: Text(_levelLabel(l10n, l)),
                      selected: level == l,
                      onSelected: (_) => onLevelChanged(l),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(color: level == l ? Colors.white : AppColors.textPrimary),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.language, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(languageName, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: AppSpacing.xl),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.adminEstimatedHoursLabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminTagsLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          _ChipInput(controller: tagInputController, values: tags, onAdd: onAddTag, onRemove: onRemoveTag, hint: l10n.adminAddTagHint),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminLearningObjectivesLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          _ChipInput(
            controller: objectiveInputController,
            values: objectives,
            onAdd: onAddObjective,
            onRemove: onRemoveObjective,
            hint: l10n.adminAddObjectiveHint,
          ),
        ],
      ),
    );
  }
}

class _ChipInput extends StatelessWidget {
  const _ChipInput({
    required this.controller,
    required this.values,
    required this.onAdd,
    required this.onRemove,
    required this.hint,
  });

  final TextEditingController controller;
  final List<String> values;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) onAdd(trimmed);
            controller.clear();
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final v in values)
              Chip(
                label: Text(v),
                onDeleted: () => onRemove(v),
              ),
          ],
        ),
      ],
    );
  }
}

class _CurriculumStep extends StatelessWidget {
  const _CurriculumStep({
    required this.course,
    required this.onAddModule,
    required this.onRenameModule,
    required this.onDeleteModule,
    required this.onAddLesson,
    required this.onEditLesson,
    required this.onDeleteLesson,
    required this.onMoveLesson,
    required this.onReorderLesson,
  });

  final AdminCourseDetail? course;
  final VoidCallback onAddModule;
  final void Function(AdminModule) onRenameModule;
  final void Function(AdminModule) onDeleteModule;
  final void Function(AdminModule) onAddLesson;
  final void Function(AdminLesson) onEditLesson;
  final void Function(AdminLesson) onDeleteLesson;
  final void Function(AdminLesson) onMoveLesson;
  final void Function(AdminModule, AdminLesson) onReorderLesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.adminModulesLessonsTitle, style: AppTypography.title),
              TextButton.icon(onPressed: onAddModule, icon: const Icon(Icons.add), label: Text(l10n.adminAddModuleTitle)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (course == null || course!.modules.isEmpty)
            Text(l10n.adminNoModulesYetMessage, style: AppTypography.caption)
          else
            ...course!.modules.map(
              (module) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: AppRadius.small),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(module.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.title.copyWith(fontSize: 16)),
                      subtitle: Text(l10n.adminLessonsCountLabel(module.lessons.length)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit_outlined), tooltip: l10n.adminRenameModuleTooltip, onPressed: () => onRenameModule(module)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            tooltip: l10n.adminDeleteModuleTooltip,
                            onPressed: () => onDeleteModule(module),
                          ),
                        ],
                      ),
                      children: [
                        ...module.lessons.map(
                          (lesson) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                              child: Text('${lesson.orderNumber}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ),
                            title: Text(lesson.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(lesson.summary, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    onEditLesson(lesson);
                                  case 'blocks':
                                    context.push('/admin/lessons/${lesson.id}/edit', extra: lesson.title);
                                  case 'move':
                                    onMoveLesson(lesson);
                                  case 'reorder':
                                    onReorderLesson(module, lesson);
                                  case 'images':
                                    context.push('/admin/lessons/${lesson.id}/images', extra: lesson.title);
                                  case 'quiz':
                                    context.push('/admin/lessons/${lesson.id}/quiz', extra: lesson.title);
                                  case 'delete':
                                    onDeleteLesson(lesson);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(value: 'edit', child: Text(l10n.commonEdit)),
                                PopupMenuItem(value: 'blocks', child: Text(l10n.adminMenuBlockEditor)),
                                PopupMenuItem(value: 'move', child: Text(l10n.adminMenuMoveToAnotherModule)),
                                PopupMenuItem(value: 'reorder', child: Text(l10n.adminMenuChangePosition)),
                                PopupMenuItem(value: 'images', child: Text(l10n.adminMenuManageImages)),
                                PopupMenuItem(value: 'quiz', child: Text(l10n.adminMenuManageQuiz)),
                                const PopupMenuDivider(),
                                PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete, style: const TextStyle(color: AppColors.error))),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(onPressed: () => onAddLesson(module), icon: const Icon(Icons.add), label: Text(l10n.adminAddLessonButton)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LearningResourcesStep extends StatelessWidget {
  const _LearningResourcesStep({
    required this.supportLanguageInputController,
    required this.supportLanguageCodes,
    required this.onAddSupportLanguage,
    required this.onRemoveSupportLanguage,
    required this.prerequisiteCourseId,
    required this.languageCourses,
    required this.onPrerequisiteChanged,
  });

  final TextEditingController supportLanguageInputController;
  final List<String> supportLanguageCodes;
  final ValueChanged<String> onAddSupportLanguage;
  final ValueChanged<String> onRemoveSupportLanguage;
  final String? prerequisiteCourseId;
  final List<AdminCourseDetail> languageCourses;
  final ValueChanged<String?> onPrerequisiteChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminWizardStepResources, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.adminSupportLanguageCodesLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          _ChipInput(
            controller: supportLanguageInputController,
            values: supportLanguageCodes,
            onAdd: onAddSupportLanguage,
            onRemove: onRemoveSupportLanguage,
            hint: l10n.adminSupportLanguageHint,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.adminPrerequisiteCourseLabel, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          DropdownButton<String?>(
            isExpanded: true,
            value: prerequisiteCourseId,
            hint: Text(l10n.commonNone),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.commonNone)),
              for (final c in languageCourses) DropdownMenuItem(value: c.id, child: Text(c.title, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: onPrerequisiteChanged,
          ),
        ],
      ),
    );
  }
}

class _AssessmentStep extends StatelessWidget {
  const _AssessmentStep({required this.course, required this.languageId, required this.languageName});

  final AdminCourseDetail? course;
  final String languageId;
  final String? languageName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lessons = course?.modules.expand((m) => m.lessons).toList() ?? [];

    return _StepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminWizardStepAssessment, style: AppTypography.title),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.adminManageQuizFromBuilderMessage, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          if (lessons.isEmpty)
            Text(l10n.adminAddLessonsFirstMessage, style: AppTypography.caption)
          else
            ...lessons.map(
              (lesson) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.quiz_outlined, color: AppColors.ai),
                title: Text(lesson.title),
                trailing: TextButton(
                  onPressed: () => context.push('/admin/lessons/${lesson.id}/quiz', extra: lesson.title),
                  child: Text(l10n.adminManageQuizButton),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewPublishStep extends StatelessWidget {
  const _ReviewPublishStep({
    required this.course,
    required this.readiness,
    required this.publicationDate,
    required this.onPublicationDateChanged,
    required this.onPublish,
  });

  final AdminCourseDetail? course;
  final ({int completionPercent, bool courseDetailsComplete, int lessonsReadyCount, int lessonsTotalCount, int lessonsMissingAudioCount, bool assessmentComplete})?
      readiness;
  final DateTime? publicationDate;
  final ValueChanged<DateTime?> onPublicationDateChanged;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StepCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.adminWizardStepReview, style: AppTypography.title),
              if (course != null) StatusPill(status: course!.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (course != null) ...[
            Text(course!.title, style: AppTypography.h2.copyWith(fontSize: 20)),
            if (course!.subtitle.isNotEmpty) Text(course!.subtitle, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            Text(course!.description, style: AppTypography.body),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _summaryChip(Icons.menu_book, l10n.adminModulesCountLabel(course!.modules.length)),
                _summaryChip(Icons.play_lesson, l10n.adminLessonsCountLabel(course!.modules.expand((m) => m.lessons).length)),
                _summaryChip(Icons.bar_chart, _levelLabel(l10n, course!.level)),
                if (course!.estimatedHours != null) _summaryChip(Icons.timer_outlined, l10n.adminHoursSuffixLabel(course!.estimatedHours!)),
              ],
            ),
          ],
          if (readiness != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.adminReadinessChecklistTitle, style: AppTypography.title.copyWith(fontSize: 15)),
            const SizedBox(height: AppSpacing.sm),
            _checklistRow(l10n.adminChecklistCourseDetailsComplete, readiness!.courseDetailsComplete),
            _checklistRow(l10n.adminChecklistLessonsReady(readiness!.lessonsReadyCount, readiness!.lessonsTotalCount), readiness!.lessonsReadyCount == readiness!.lessonsTotalCount && readiness!.lessonsTotalCount > 0),
            _checklistRow(l10n.adminChecklistAssessmentPresent, readiness!.assessmentComplete),
            _checklistRow(l10n.adminChecklistAudioMissing(readiness!.lessonsMissingAudioCount), readiness!.lessonsMissingAudioCount == 0),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: publicationDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    onPublicationDateChanged(picked);
                  },
                  icon: const Icon(Icons.event, size: 16),
                  label: Text(publicationDate == null ? l10n.adminSetPublicationDateButton : DateFormat.yMMMd().format(publicationDate!)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: onPublish,
                icon: const Icon(Icons.publish, size: 18),
                label: Text(l10n.adminPublishCourseButton),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      backgroundColor: AppColors.background,
      side: BorderSide.none,
    );
  }

  Widget _checklistRow(String label, bool complete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(complete ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: complete ? AppColors.success : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTypography.caption)),
        ],
      ),
    );
  }
}
