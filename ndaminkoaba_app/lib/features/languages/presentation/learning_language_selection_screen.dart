import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/language_repository.dart';
import '../domain/language.dart';

/// Shown both at onboarding (no learning language chosen yet — see
/// `SplashScreen.decideDestination` / `navigateAfterLogin`) and from
/// [ContinueLearningScreen] / Profile as a "Switch language" picker. Only
/// published (`isActive`) languages are offered — a language the admin is
/// still building stays hidden here even though it already has a working,
/// empty admin dashboard. When the learner already has a language selected,
/// it's excluded from the list — this screen only ever offers a *different*
/// language, since re-picking the current one wouldn't be "starting a new"
/// language at all.
class LearningLanguageSelectionScreen extends ConsumerStatefulWidget {
  const LearningLanguageSelectionScreen({super.key});

  @override
  ConsumerState<LearningLanguageSelectionScreen> createState() =>
      _LearningLanguageSelectionScreenState();
}

class _LearningLanguageSelectionScreenState
    extends ConsumerState<LearningLanguageSelectionScreen> {
  final repository = LanguageRepository();
  bool isLoading = true;
  bool isSaving = false;
  List<Language> languages = [];
  bool _onlyLanguageIsCurrent = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getLanguages(isActive: true);
      final currentLanguageId = ref.read(currentLearningLanguageProvider);
      final filtered = currentLanguageId == null
          ? result
          : result.where((l) => l.id != currentLanguageId).toList();
      if (!mounted) return;
      setState(() {
        languages = filtered;
        _onlyLanguageIsCurrent =
            currentLanguageId != null && result.isNotEmpty && filtered.isEmpty;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> select(Language language) async {
    setState(() => isSaving = true);
    await setLearningLanguage(ref, language.id);
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: l10n.chooseLanguageTitle),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 4, itemHeight: 88),
              )
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chooseLanguageQuestion,
                      style: AppTypography.h2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.chooseLanguageHint,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: languages.isEmpty
                          ? Center(
                              child: Text(
                                _onlyLanguageIsCurrent
                                    ? l10n.chooseLanguageOnlyCurrentMessage
                                    : l10n.chooseLanguageEmptyTitle,
                                style: AppTypography.caption,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              itemCount: languages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final language = languages[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: isSaving ? null : () => select(language),
                                  child: PremiumCard(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.language, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(language.name, style: AppTypography.title),
                                              if (language.country != null)
                                                Text(language.country!, style: AppTypography.caption),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
