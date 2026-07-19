import 'package:flutter/material.dart';

import '../../../../design_system/spacing/app_spacing.dart';
import '../../../../design_system/typography/app_typography.dart';

/// Prompts for a new 1-indexed position among [totalLessons] siblings.
/// Returns null if cancelled, or the chosen position (unchanged from
/// [currentPosition] is possible — callers should treat that as a no-op).
Future<int?> showReorderLessonDialog({
  required BuildContext context,
  required int currentPosition,
  required int totalLessons,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _ReorderLessonDialog(
      currentPosition: currentPosition,
      totalLessons: totalLessons,
    ),
  );
}

/// Computes the new orderNumber for every lesson whose position actually
/// changes when the lesson at [fromIndex] is moved to [toIndex] within
/// [lessons] (already sorted ascending by current orderNumber).
Map<String, int> reorderLessonPositions({
  required List<({String id, int orderNumber})> lessons,
  required int fromIndex,
  required int toIndex,
}) {
  final originalOrder = {for (final l in lessons) l.id: l.orderNumber};
  final ids = lessons.map((l) => l.id).toList();
  final movedId = ids.removeAt(fromIndex);
  ids.insert(toIndex, movedId);

  final changes = <String, int>{};
  for (var i = 0; i < ids.length; i++) {
    final newOrderNumber = i + 1;
    if (originalOrder[ids[i]] != newOrderNumber) {
      changes[ids[i]] = newOrderNumber;
    }
  }
  return changes;
}

class _ReorderLessonDialog extends StatefulWidget {
  const _ReorderLessonDialog({required this.currentPosition, required this.totalLessons});

  final int currentPosition;
  final int totalLessons;

  @override
  State<_ReorderLessonDialog> createState() => _ReorderLessonDialogState();
}

class _ReorderLessonDialogState extends State<_ReorderLessonDialog> {
  late int selectedPosition = widget.currentPosition;

  @override
  Widget build(BuildContext context) {
    final isNoOp = selectedPosition == widget.currentPosition;

    return AlertDialog(
      title: const Text('Change Lesson Position'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New position (currently Lesson ${widget.currentPosition})', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          DropdownButton<int>(
            value: selectedPosition,
            isExpanded: true,
            items: List.generate(
              widget.totalLessons,
              (i) => DropdownMenuItem(value: i + 1, child: Text('Lesson ${i + 1}')),
            ),
            onChanged: (value) => setState(() => selectedPosition = value ?? selectedPosition),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: isNoOp ? null : () => Navigator.pop(context, selectedPosition),
          child: const Text('Move'),
        ),
      ],
    );
  }
}
