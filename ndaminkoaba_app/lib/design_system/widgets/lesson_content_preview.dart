import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../cards/premium_card.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// Shown above a lesson Content field in the admin editors so admins know
/// the `**word**` markdown convention learners' bolded Ewondo words depend
/// on — pairs with [LessonContentPreview].
class MarkdownHint extends StatelessWidget {
  const MarkdownHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Text(
        'Wrap Ewondo words in ** ** to bold them, e.g. **Mbolo**.',
        style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}

/// Live-updating render of a lesson Content field, using the exact same
/// style the real lesson screen renders with — so what the admin sees here
/// while typing is what learners will see.
class LessonContentPreview extends StatelessWidget {
  const LessonContentPreview({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PremiumCard(
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(
            p: AppTypography.lessonBody,
            strong: AppTypography.lessonBodyStrong,
          ),
        ),
      ),
    );
  }
}
