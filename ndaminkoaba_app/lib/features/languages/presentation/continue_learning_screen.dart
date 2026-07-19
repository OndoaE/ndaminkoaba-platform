import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../data/language_repository.dart';

/// Shown right after login for a returning learner who already has a
/// learning language chosen — greets them by name and asks whether to
/// continue that language or start a new one, instead of silently landing
/// on the dashboard. A brand-new learner (no language chosen yet) skips
/// this entirely and goes straight to [LearningLanguageSelectionScreen] —
/// see `post_login.dart`'s `navigateAfterLogin` and `splash_screen.dart`.
class ContinueLearningScreen extends StatefulWidget {
  const ContinueLearningScreen({super.key, required this.languageId});

  final String languageId;

  @override
  State<ContinueLearningScreen> createState() => _ContinueLearningScreenState();
}

class _ContinueLearningScreenState extends State<ContinueLearningScreen> {
  final repository = LanguageRepository();
  bool isLoading = true;
  String? languageName;
  String fullName = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final language = await repository.getLanguage(widget.languageId);
      final storedFullName = await StorageService.getFullName();
      if (!mounted) return;
      setState(() {
        languageName = language.name;
        fullName = storedFullName ?? '';
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstName = fullName.trim().isEmpty
        ? null
        : fullName.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.waving_hand_outlined, color: AppColors.primary, size: 40),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        firstName != null
                            ? l10n.continueLearningWelcomeBack(firstName)
                            : l10n.continueLearningWelcomeBackNoName,
                        style: AppTypography.h1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.continueLearningSubtitle,
                        style: AppTypography.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => context.go('/dashboard'),
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
                                child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      languageName != null
                                          ? l10n.continueLearningContinueTitle(languageName!)
                                          : l10n.continueLearningContinueFallback,
                                      style: AppTypography.title,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      l10n.continueLearningContinueSubtitle,
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => context.push('/select-learning-language'),
                        child: PremiumCard(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add_circle_outline, color: AppColors.secondary),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.continueLearningNewLanguageTitle, style: AppTypography.title),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      l10n.continueLearningNewLanguageSubtitle,
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                            ],
                          ),
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
