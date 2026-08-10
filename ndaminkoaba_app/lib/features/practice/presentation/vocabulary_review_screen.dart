import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/badge_earned_dialog.dart';
import '../../../design_system/widgets/pagination_dots.dart';
import '../../../l10n/app_localizations.dart';
import '../../badges/domain/badge_entry.dart';
import '../data/vocabulary_review_repository.dart';
import '../domain/review_item.dart';

/// Smart Review flow — cycles through due words, one at a time. Learners
/// tap a recall-quality button (mapped to SM-2 grades) instead of typing an
/// answer; grading is self-assessed, matching how spaced-repetition apps
/// like Anki work.
class VocabularyReviewScreen extends ConsumerStatefulWidget {
  const VocabularyReviewScreen({super.key, required this.items});

  final List<ReviewItem> items;

  @override
  ConsumerState<VocabularyReviewScreen> createState() =>
      _VocabularyReviewScreenState();
}

class _VocabularyReviewScreenState
    extends ConsumerState<VocabularyReviewScreen> {
  final repository = VocabularyReviewRepository();

  int index = 0;
  bool revealed = false;
  bool isGrading = false;

  Future<void> _grade(int grade) async {
    if (isGrading) return;
    setState(() => isGrading = true);
    var newlyEarnedBadges = <BadgeEntry>[];
    try {
      newlyEarnedBadges = await repository.grade(
        widget.items[index].vocabularyId,
        grade,
      );
    } catch (_) {
      // Best-effort — move on regardless so one failed grade doesn't strand
      // the learner mid-review.
    }
    if (!mounted) return;
    if (newlyEarnedBadges.isNotEmpty) {
      await BadgeEarnedDialog.show(context, newlyEarnedBadges);
    }
    if (!mounted) return;
    if (index < widget.items.length - 1) {
      setState(() {
        index++;
        revealed = false;
        isGrading = false;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';
    final word = widget.items[index].vocabulary;
    final meaning = isFrench ? word.frenchMeaning : word.englishMeaning;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.smartReviewTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              PaginationDots(count: widget.items.length, currentIndex: index),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => revealed = true),
                child: PremiumCard(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          word.word,
                          style: AppTypography.h1,
                          textAlign: TextAlign.center,
                        ),
                        if (revealed) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            meaning ?? '',
                            style: AppTypography.title,
                            textAlign: TextAlign.center,
                          ),
                          if (word.exampleSentence != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              word.exampleSentence!,
                              style: AppTypography.caption,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.tapToRevealHint,
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (revealed)
                Row(
                  children: [
                    Expanded(
                      child: _GradeButton(
                        label: l10n.gradeAgainLabel,
                        color: AppColors.error,
                        onTap: () => _grade(0),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _GradeButton(
                        label: l10n.gradeHardLabel,
                        color: AppColors.warning,
                        onTap: () => _grade(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _GradeButton(
                        label: l10n.gradeGoodLabel,
                        color: AppColors.primary,
                        onTap: () => _grade(4),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _GradeButton(
                        label: l10n.gradeEasyLabel,
                        color: AppColors.success,
                        onTap: () => _grade(5),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
