import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';

/// Color-coded status chip used across the admin relaunch tables/cards —
/// Published/Active=green, Draft=gold, In Review=blue, Archived=gray,
/// Approved=teal.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  ({Color bg, Color fg, String label}) _style(AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'PUBLISHED':
        return (bg: AppColors.success.withValues(alpha: 0.15), fg: AppColors.success, label: l10n.adminWorkflowPublished);
      case 'ACTIVE':
        return (bg: AppColors.success.withValues(alpha: 0.15), fg: AppColors.success, label: l10n.adminStatusActive);
      case 'READY':
        return (bg: AppColors.success.withValues(alpha: 0.15), fg: AppColors.success, label: l10n.adminReadyLabel);
      case 'DRAFT':
        return (bg: AppColors.secondary.withValues(alpha: 0.18), fg: const Color(0xFF8A6D1A), label: l10n.adminWorkflowDraft);
      case 'IN_REVIEW':
        return (bg: AppColors.ai.withValues(alpha: 0.15), fg: AppColors.ai, label: l10n.adminWorkflowInReview);
      case 'APPROVED':
        return (bg: const Color(0xFF0E8C7C).withValues(alpha: 0.15), fg: const Color(0xFF0E8C7C), label: l10n.adminWorkflowApproved);
      case 'ARCHIVED':
        return (bg: AppColors.divider, fg: AppColors.textSecondary, label: l10n.adminWorkflowArchived);
      case 'INACTIVE':
        return (bg: AppColors.divider, fg: AppColors.textSecondary, label: _titleCase(status));
      default:
        return (bg: AppColors.divider, fg: AppColors.textSecondary, label: _titleCase(status));
    }
  }

  String _titleCase(String value) {
    final words = value.toLowerCase().split('_');
    return words.map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final style = _style(AppLocalizations.of(context));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(color: style.bg, borderRadius: AppRadius.circle),
      child: Text(
        style.label,
        style: TextStyle(color: style.fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
