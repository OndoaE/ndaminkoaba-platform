import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../cards/premium_card.dart';
import '../colors/app_colors.dart';
import '../markdown/nda_markdown_extensions.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Shown above a lesson Content field in the admin editors so admins know
/// the markdown conventions learners' formatted content depends on — select
/// text in the field above to apply these via the formatting toolbar
/// instead of typing them by hand. Pairs with [LessonContentPreview].
class MarkdownHint extends StatelessWidget {
  const MarkdownHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Text(
        'Select text above to format it — bold, italic, underline, links, '
        'bullet and numbered lists. Press Enter inside a list to continue it '
        'automatically.',
        style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}

/// Live-updating render of a lesson Content field, using the exact same
/// style the real lesson screen renders with — so what the admin sees here
/// while typing is what learners will see.
///
/// Deliberately set apart from the field above it (top spacing, a divider,
/// and an explicit "Preview" label) rather than sitting flush beneath it —
/// it re-renders the *same* text the admin just typed, in a different font,
/// so with no separation a selected word can visually land right above its
/// own re-rendered copy and read as a duplicate/rendering glitch rather
/// than the intentional live preview it is.
class LessonContentPreview extends StatelessWidget {
  const LessonContentPreview({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.divider, height: AppSpacing.lg),
          Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'PREVIEW — what learners will see',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PremiumCard(
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: AppTypography.lessonBody,
                strong: AppTypography.lessonBodyStrong,
              ),
              softLineBreak: true,
              inlineSyntaxes: ndaMarkdownInlineSyntaxes,
              builders: ndaMarkdownBuilders,
              onTapLink: ndaMarkdownOnTapLink,
            ),
          ),
        ],
      ),
    );
  }
}
