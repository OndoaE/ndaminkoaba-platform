import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/network/api_error.dart';
import '../../../design_system/buttons/bouncy_icon_button.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/navigation/learner_shell.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../offline/data/offline_course_repository.dart';
import '../data/vocabulary_repository.dart';
import '../domain/vocabulary_word.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

String _levelLabel(AppLocalizations l10n, String level) {
  switch (level) {
    case 'BEGINNER':
      return l10n.levelBeginner;
    case 'INTERMEDIATE':
      return l10n.levelIntermediate;
    case 'ADVANCED':
      return l10n.levelAdvanced;
    default:
      return level;
  }
}

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  final repository = VocabularyRepository();
  final offlineCourseRepository = OfflineCourseRepository();
  final searchController = TextEditingController();

  String? selectedLevel;
  bool isLoading = true;
  bool hasError = false;
  bool isOfflineFallback = false;
  List<VocabularyWord> words = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      hasError = false;
      isOfflineFallback = false;
    });
    try {
      final result = await repository.getVocabulary(
        difficulty: selectedLevel,
        search: searchController.text.trim(),
        languageId: ref.read(currentLearningLanguageProvider),
      );
      if (!mounted) return;
      setState(() {
        words = result;
        isLoading = false;
      });
    } catch (e) {
      final isConnectivityIssue =
          !kIsWeb && e is DioException && isConnectivityFailure(e);
      if (isConnectivityIssue && await _loadFromOfflineCache()) return;

      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  /// Falls back to whatever vocabulary is sitting in already-downloaded
  /// courses when the live fetch fails for connectivity reasons — no
  /// whole-catalog caching, just the words a learner's downloads already
  /// carry. Applies the same level/search filters client-side. Returns
  /// whether any cached words were found.
  Future<bool> _loadFromOfflineCache() async {
    final courseIds = await offlineCourseRepository.getDownloadedCourseIds();
    if (courseIds.isEmpty) return false;

    final seenWordIds = <String>{};
    final offlineWords = <VocabularyWord>[];
    for (final courseId in courseIds) {
      final manifest = await offlineCourseRepository.loadManifest(courseId);
      if (manifest == null) continue;
      for (final lesson in manifest.orderedLessons) {
        for (final entry in lesson.vocabulary) {
          if (!seenWordIds.add(entry.word.id)) continue;
          offlineWords.add(entry.word);
        }
      }
    }

    final searchText = searchController.text.trim().toLowerCase();
    final filtered = offlineWords.where((word) {
      if (selectedLevel != null && word.difficulty != selectedLevel) {
        return false;
      }
      if (searchText.isEmpty) return true;
      return word.word.toLowerCase().contains(searchText) ||
          (word.englishMeaning ?? '').toLowerCase().contains(searchText) ||
          (word.frenchMeaning ?? '').toLowerCase().contains(searchText);
    }).toList();

    if (!mounted) return true;
    setState(() {
      words = filtered;
      isOfflineFallback = true;
      isLoading = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LearnerShell(
      activeNavKey: 'vocabulary',
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BouncyIconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      l10n.vocabularyTitle,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (isOfflineFallback) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.downloadedOfflineLabel,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              GradientHeroCard(
                gradient: AppGradients.primary,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.translate, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        l10n.vocabularyHeroText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PremiumTextField(
                hint: l10n.searchWordsHint,
                controller: searchController,
                prefixIcon: Icons.search,
                onSubmitted: (_) => load(),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _LevelChip(
                      label: l10n.levelAllShort,
                      selected: selectedLevel == null,
                      onTap: () {
                        setState(() => selectedLevel = null);
                        load();
                      },
                    ),
                    ..._levels.map(
                      (level) => Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: _LevelChip(
                          label: _levelLabel(l10n, level),
                          selected: selectedLevel == level,
                          onTap: () {
                            setState(() => selectedLevel = level);
                            load();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const ShimmerListLoader(itemCount: 5, itemHeight: 92)
                    : hasError
                    ? EmptyState(
                        icon: Icons.wifi_off_outlined,
                        iconColor: AppColors.error,
                        title: l10n.commonSomethingWrong,
                        action: PrimaryButton(
                          label: l10n.commonRetry,
                          onPressed: load,
                        ),
                      )
                    : words.isEmpty
                    ? EmptyState(
                        icon: Icons.translate,
                        title: l10n.noWordsFoundTitle,
                        message: l10n.noWordsFoundMessage,
                      )
                    : ListView.separated(
                        itemCount: words.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) =>
                            _VocabularyCard(word: words[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      showCheckmark: false,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.primary : Colors.black12),
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _VocabularyCard extends ConsumerWidget {
  const _VocabularyCard({required this.word});

  final VocabularyWord word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isFrench = ref.watch(localeProvider).languageCode == 'fr';
    final meaning = isFrench
        ? word.frenchMeaning ?? word.englishMeaning
        : word.englishMeaning ?? word.frenchMeaning;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(word.word, style: AppTypography.title)),
              if (word.difficulty.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _levelLabel(l10n, word.difficulty),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (meaning != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(meaning, style: AppTypography.caption),
          ],
          if (word.exampleSentence != null &&
              word.exampleSentence!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              word.exampleSentence!,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
