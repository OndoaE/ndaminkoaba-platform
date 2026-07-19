import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_hero_card.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/certificate_repository.dart';
import '../domain/certificate.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final repository = CertificateRepository();

  late Future<List<Certificate>> certificatesFuture;

  @override
  void initState() {
    super.initState();
    certificatesFuture = repository.getMyCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Certificate>>(
          future: certificatesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 3, itemHeight: 96),
              );
            }

            final certificates = snapshot.data!;
            final l10n = AppLocalizations.of(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
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
            );
          },
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
    return GradientHeroCard(
      gradient: AppGradients.gold,
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
                Text(
                  certificate.certificateCode,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
