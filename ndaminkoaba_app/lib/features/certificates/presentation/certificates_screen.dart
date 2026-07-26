import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/buttons/bouncy_icon_button.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/level_stars.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/certificate_repository.dart';
import '../domain/certificate.dart';
import '../domain/certificate_theme.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final repository = CertificateRepository();

  bool isLoading = true;
  bool hasError = false;
  List<Certificate> certificates = [];

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
    try {
      final result = await repository.getMyCertificates();
      if (!mounted) return;
      setState(() {
        certificates = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 3, itemHeight: 96),
              )
            : hasError
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: EmptyState(
                  icon: Icons.wifi_off_outlined,
                  iconColor: AppColors.error,
                  title: l10n.commonSomethingWrong,
                  action: PrimaryButton(
                    label: l10n.commonRetry,
                    onPressed: load,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BouncyIconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.myCertificatesTitle,
                      style: AppTypography.h1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.myCertificatesSubtitle,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (certificates.isEmpty)
                      EmptyState(
                        icon: Icons.workspace_premium_outlined,
                        iconColor: AppColors.secondary,
                        title: l10n.noCertificatesTitle,
                        message: l10n.noCertificatesMessage,
                      )
                    else
                      ...certificates.map(
                        (certificate) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () =>
                                context.push('/certificates/${certificate.id}'),
                            child: _CertificateCard(certificate: certificate),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    final theme = certificateThemeForLevel(certificate.level);
    return GradientHeroCard(
      gradient: theme.gradient,
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.courseTitle,
                  style: AppTypography.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      certificate.certificateCode,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    LevelStars(count: theme.starCount, size: 14),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}
