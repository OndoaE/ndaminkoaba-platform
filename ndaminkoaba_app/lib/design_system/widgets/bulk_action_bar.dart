import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Inline bar that appears above a data table once rows are checkbox-
/// selected — "N selected" plus caller-supplied action buttons (Publish,
/// Archive, Assign Reviewer, Export, ...).
class BulkActionBar extends StatelessWidget {
  const BulkActionBar({super.key, required this.selectedCount, required this.actions});

  final int selectedCount;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text('$selectedCount selected', style: AppTypography.title.copyWith(fontSize: 14)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: actions),
          ),
        ],
      ),
    );
  }
}
