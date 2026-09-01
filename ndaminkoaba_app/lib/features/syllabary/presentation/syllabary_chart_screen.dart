import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/syllabary_repository.dart';
import '../domain/syllabary_models.dart';

/// The syllable chart for one letter: every vowel row (syllable, example
/// word, French translation, example sentence), in the order the admin
/// approved them in.
class SyllabaryChartScreen extends ConsumerStatefulWidget {
  const SyllabaryChartScreen({super.key, required this.letter});

  final String letter;

  @override
  ConsumerState<SyllabaryChartScreen> createState() => _SyllabaryChartScreenState();
}

class _SyllabaryChartScreenState extends ConsumerState<SyllabaryChartScreen> {
  final repository = SyllabaryRepository();
  bool isLoading = true;
  bool hasError = false;
  List<SyllabaryEntry> rows = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final languageId = ref.read(currentLearningLanguageProvider);
    if (languageId == null) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final result = await repository.getChart(languageId, widget.letter);
      if (!mounted) return;
      setState(() {
        rows = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  /// Prefers the translation matching the UI locale, falling back to the
  /// other language when the preferred one hasn't been authored yet
  /// (many existing rows only have a French translation from AI
  /// extraction; English is filled in later by an admin, if at all) —
  /// showing something beats showing nothing.
  String? _translationFor(SyllabaryEntry row, bool isFrench) {
    final preferred = isFrench ? row.frenchTranslation : row.englishTranslation;
    final fallback = isFrench ? row.englishTranslation : row.frenchTranslation;
    return (preferred != null && preferred.isNotEmpty) ? preferred : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: '"${widget.letter}"'),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(),
              )
            : (hasError || rows.isEmpty)
                ? const EmptyState(
                    icon: Icons.grid_view_outlined,
                    title: 'Nothing here yet',
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      Center(
                        child: Text(
                          widget.letter,
                          style: AppTypography.display.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ...rows.map(
                        (row) {
                          final translation = _translationFor(row, isFrench);
                          return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: PremiumCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                                  child: Text(
                                    row.syllable,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (row.exampleWord != null)
                                        Text(row.exampleWord!, style: AppTypography.title),
                                      if (translation != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            translation,
                                            style: AppTypography.caption,
                                          ),
                                        ),
                                      if (row.exampleSentence != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                                          child: Text(
                                            row.exampleSentence!,
                                            style: AppTypography.caption.copyWith(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}
