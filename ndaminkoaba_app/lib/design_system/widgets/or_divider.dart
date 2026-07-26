import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label, this.showLines = true});

  final String? label;

  /// Set false for the flat-text variant used on the auth screens' mockups
  /// (no flanking horizontal rules, just centered text).
  final bool showLines;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label ?? AppLocalizations.of(context).commonOrContinueWith,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
    );

    if (!showLines) {
      return Center(child: text);
    }

    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: text,
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
