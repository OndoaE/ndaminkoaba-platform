import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../shadows/app_shadows.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// One column header for [AdminDataTable] — [flex] controls its relative
/// width, matching how the caller lays out each row's cells.
class AdminTableColumn {
  const AdminTableColumn(this.label, {this.flex = 1});

  final String label;
  final int flex;
}

/// Lightweight, hand-built data-table shell used across the admin relaunch
/// (Language Management, Course Management, etc.) — a styled header row
/// plus a caller-supplied list of row widgets. No Flutter/web package
/// matches this card-table aesthetic closely enough to justify pulling one
/// in for 2-3 tables; callers build each row as a `Row` of `Expanded(flex:
/// ...)` cells matching [columns] so header and body stay aligned.
class AdminDataTable extends StatelessWidget {
  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.leadingWidth,
  });

  final List<AdminTableColumn> columns;
  final List<Widget> rows;

  /// Reserves space before the first column for a checkbox, if the caller's
  /// rows include one — keeps the header cells aligned with row cells.
  final double? leadingWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                if (leadingWidth != null) SizedBox(width: leadingWidth),
                for (final column in columns)
                  Expanded(
                    flex: column.flex,
                    child: Text(
                      column.label,
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
          for (final row in rows)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: row,
            ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(child: Text(AppLocalizations.of(context).commonNoResults, style: AppTypography.caption)),
            ),
        ],
      ),
    );
  }
}
