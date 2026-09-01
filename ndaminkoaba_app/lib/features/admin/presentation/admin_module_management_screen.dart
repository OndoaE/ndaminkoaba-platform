import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';
import '../data/content_repository.dart';
import '../domain/admin_models.dart';
import '../domain/management_models.dart';

class AdminModuleManagementScreen extends StatefulWidget {
  const AdminModuleManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminModuleManagementScreen> createState() => _AdminModuleManagementScreenState();
}

class _AdminModuleManagementScreenState extends State<AdminModuleManagementScreen> {
  final adminRepository = AdminRepository();
  final contentRepository = ContentRepository();
  final searchController = TextEditingController();

  bool isLoading = true;
  List<ManagedModule> modules = [];
  List<AdminCourse> courses = [];
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
        contentRepository.getAllModulesFlat(languageId: widget.languageId),
        adminRepository.getCourses(languageId: widget.languageId),
      ]);
      if (!mounted) return;
      setState(() {
        modules = results[0] as List<ManagedModule>;
        courses = results[1] as List<AdminCourse>;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<ManagedModule> get _visible {
    final query = searchController.text.trim().toLowerCase();
    return modules.where((m) {
      final matchesCourse = courseFilter == null || m.courseId == courseFilter;
      final matchesQuery = query.isEmpty || m.title.toLowerCase().contains(query);
      return matchesCourse && matchesQuery;
    }).toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> addModule() async {
    final l10n = AppLocalizations.of(context);
    if (courses.isEmpty) {
      _showMessage(l10n.adminModuleMgmtCreateCourseFirst);
      return;
    }

    final result = await showDialog<_ModuleFormResult>(
      context: context,
      builder: (context) => _ModuleFormDialog(courses: courses),
    );
    if (result == null) return;

    final orderNumber = modules.where((m) => m.courseId == result.courseId).length + 1;

    try {
      await contentRepository.createModule(
        courseId: result.courseId,
        title: result.title,
        description: result.description,
        frenchTitle: result.frenchTitle,
        frenchDescription: result.frenchDescription,
        orderNumber: orderNumber,
      );
      load();
      _showMessage(l10n.adminModuleMgmtCreatedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminModuleMgmtCreateError));
    }
  }

  Future<void> editModule(ManagedModule module) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<_ModuleFormResult>(
      context: context,
      builder: (context) => _ModuleFormDialog(courses: courses, initial: module),
    );
    if (result == null) return;

    try {
      await contentRepository.updateModule(
        module.id,
        title: result.title,
        description: result.description,
        frenchTitle: result.frenchTitle,
        frenchDescription: result.frenchDescription,
      );
      load();
      _showMessage(l10n.adminModuleMgmtUpdatedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminModuleMgmtUpdateError));
    }
  }

  Future<void> deleteModule(ManagedModule module) async {
    final l10n = AppLocalizations.of(context);
    if (module.lessonCount > 0) {
      _showMessage(l10n.adminModuleMgmtDeleteLessonsFirst(module.lessonCount));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.adminModuleMgmtDeleteTitle),
          content: Text(l10n.adminModuleMgmtDeleteBody(module.title)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.adminModuleMgmtCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.adminModuleMgmtDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      await contentRepository.deleteModule(module.id);
      load();
      _showMessage(l10n.adminModuleMgmtDeletedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminModuleMgmtDeleteError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: l10n.adminModuleMgmtAppBarTitle, colors: const [Color(0xFF0D7A4C), AppColors.primary]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D7A4C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.adminModuleMgmtNewModule, style: const TextStyle(color: Colors.white)),
        onPressed: addModule,
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
                  hintText: l10n.adminModuleMgmtSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (courses.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: l10n.adminModuleMgmtAllCourses,
                        selected: courseFilter == null,
                        onTap: () => setState(() => courseFilter = null),
                      ),
                      ...courses.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: _FilterChip(
                            label: c.title,
                            selected: courseFilter == c.id,
                            onTap: () => setState(() => courseFilter = c.id),
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
                        ? Center(child: Text(l10n.adminModuleMgmtNoModulesFound, style: AppTypography.caption))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _visible.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final module = _visible[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () => editModule(module),
                                child: PremiumCard(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D7A4C).withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.view_module, color: Color(0xFF0D7A4C)),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(module.title, style: AppTypography.title),
                                            Text(
                                              l10n.adminModuleMgmtCourseLessonsSummary(module.courseTitle, module.lessonCount),
                                              style: AppTypography.caption,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => editModule(module),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                        onPressed: () => deleteModule(module),
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
      selectedColor: const Color(0xFF0D7A4C),
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
    );
  }
}

class _ModuleFormResult {
  const _ModuleFormResult({
    required this.courseId,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
  });

  final String courseId;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
}

class _ModuleFormDialog extends StatefulWidget {
  const _ModuleFormDialog({required this.courses, this.initial});

  final List<AdminCourse> courses;
  final ManagedModule? initial;

  @override
  State<_ModuleFormDialog> createState() => _ModuleFormDialogState();
}

class _ModuleFormDialogState extends State<_ModuleFormDialog> {
  late final titleController = TextEditingController(text: widget.initial?.title ?? '');
  late final descriptionController = TextEditingController(text: widget.initial?.description ?? '');
  late final frenchTitleController = TextEditingController(text: widget.initial?.frenchTitle ?? '');
  late final frenchDescriptionController =
      TextEditingController(text: widget.initial?.frenchDescription ?? '');
  late String courseId = widget.initial?.courseId ?? widget.courses.first.id;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    frenchTitleController.dispose();
    frenchDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.initial != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.adminModuleMgmtEditTitle : l10n.adminModuleMgmtNewModule),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditing) ...[
              Text(l10n.adminModuleMgmtCourseLabel, style: AppTypography.caption),
              DropdownButton<String>(
                value: courseId,
                isExpanded: true,
                items: widget.courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
                onChanged: (value) => setState(() => courseId = value ?? courseId),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.adminModuleMgmtTitleLabel)),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: l10n.adminModuleMgmtDescriptionLabel)),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: frenchTitleController,
              decoration: InputDecoration(labelText: l10n.adminModuleMgmtFrenchTitleLabel),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: frenchDescriptionController,
              decoration: InputDecoration(labelText: l10n.adminModuleMgmtFrenchDescriptionLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.adminModuleMgmtCancel)),
        FilledButton(
          onPressed: () {
            if (titleController.text.trim().length < 3) return;
            Navigator.pop(
              context,
              _ModuleFormResult(
                courseId: courseId,
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                frenchTitle: frenchTitleController.text.trim(),
                frenchDescription: frenchDescriptionController.text.trim(),
              ),
            );
          },
          child: Text(isEditing ? l10n.adminModuleMgmtSave : l10n.adminModuleMgmtCreate),
        ),
      ],
    );
  }
}
