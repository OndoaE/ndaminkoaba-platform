import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/logo_header.dart';
import '../../../l10n/app_localizations.dart';

/// Shown once, on the very first app launch on this device, before the
/// learner ever sees the Login screen — see `SplashScreen.decideDestination`.
class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
  ) async {
    await setAppLocale(ref, locale);
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFEAD9), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    const LogoHeader(
                      title: 'NdaMinkoaba',
                      subtitle: 'Learn • Preserve • Transmit',
                      imagePath: 'assets/images/ndaminkoaba_logo.png',
                      size: 140,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(l10n.languageSelectTitle, style: AppTypography.h2),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.languageSelectSubtitle,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _LanguageOption(
                      flag: '🇬🇧',
                      label: l10n.languageEnglishLabel,
                      onTap: () => _select(context, ref, const Locale('en')),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LanguageOption(
                      flag: '🇫🇷',
                      label: l10n.languageFrenchLabel,
                      onTap: () => _select(context, ref, const Locale('fr')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.onTap,
  });

  final String flag;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: PremiumCard(
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(label, style: AppTypography.title),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
