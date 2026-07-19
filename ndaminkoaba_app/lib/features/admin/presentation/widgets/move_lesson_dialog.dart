import 'package:flutter/material.dart';

import '../../../../design_system/colors/app_colors.dart';
import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';
import '../../domain/management_models.dart';

class MoveLessonResult {
  const MoveLessonResult({required this.moduleId, required this.orderNumber});

  final String moduleId;
  final int orderNumber;
}

/// Lets an admin pick a destination course + module for a lesson, from the
/// full platform-wide module list (so a lesson can move to a module in a
/// different course, including a course at a different level).
Future<MoveLessonResult?> showMoveLessonDialog({
  required BuildContext context,
  required List<ManagedModule> modules,
  required String currentModuleId,
}) {
  return showDialog<MoveLessonResult>(
    context: context,
    builder: (context) => _MoveLessonDialog(modules: modules, currentModuleId: currentModuleId),
  );
}

class _MoveLessonDialog extends StatefulWidget {
  const _MoveLessonDialog({required this.modules, required this.currentModuleId});

  final List<ManagedModule> modules;
  final String currentModuleId;

  @override
  State<_MoveLessonDialog> createState() => _MoveLessonDialogState();
}

class _MoveLessonDialogState extends State<_MoveLessonDialog> {
  late String selectedCourseId;
  late String selectedModuleId;

  ManagedModule? get _currentModule =>
      widget.modules.where((m) => m.id == widget.currentModuleId).firstOrNull;

  List<({String id, String title, String level})> get _courses {
    final seen = <String>{};
    final result = <({String id, String title, String level})>[];
    for (final m in widget.modules) {
      if (seen.add(m.courseId)) {
        result.add((id: m.courseId, title: m.courseTitle, level: m.courseLevel));
      }
    }
    result.sort((a, b) => a.title.compareTo(b.title));
    return result;
  }

  List<ManagedModule> get _modulesForSelectedCourse =>
      widget.modules.where((m) => m.courseId == selectedCourseId).toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

  @override
  void initState() {
    super.initState();
    final current = _currentModule;
    selectedCourseId = current?.courseId ?? (widget.modules.isNotEmpty ? widget.modules.first.courseId : '');
    selectedModuleId = widget.currentModuleId;
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    final modulesForCourse = _modulesForSelectedCourse;
    final isNoOp = selectedModuleId == widget.currentModuleId;

    return AlertDialog(
      title: const Text('Move Lesson'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destination course', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            DropdownButton<String>(
              value: selectedCourseId,
              isExpanded: true,
              items: courses
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.title} (${c.level[0]}${c.level.substring(1).toLowerCase()})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedCourseId = value;
                  final modules = widget.modules.where((m) => m.courseId == value).toList();
                  selectedModuleId = modules.isNotEmpty ? modules.first.id : '';
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Destination module', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            DropdownButton<String>(
              value: selectedModuleId.isEmpty ? null : selectedModuleId,
              isExpanded: true,
              items: modulesForCourse
                  .map((m) => DropdownMenuItem(value: m.id, child: Text(m.title)))
                  .toList(),
              onChanged: (value) => setState(() => selectedModuleId = value ?? selectedModuleId),
            ),
            if (isNoOp) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'This lesson is already in that module.',
                style: AppTypography.caption.copyWith(color: AppColors.warning),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: (selectedModuleId.isEmpty || isNoOp)
              ? null
              : () {
                  final target = widget.modules.firstWhere((m) => m.id == selectedModuleId);
                  Navigator.pop(
                    context,
                    MoveLessonResult(moduleId: target.id, orderNumber: target.lessonCount + 1),
                  );
                },
          child: const Text('Move'),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
