import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/app_config.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/cards/premium_card.dart';
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

class CertificateDetailScreen extends StatefulWidget {
  const CertificateDetailScreen({super.key, required this.certificateId});

  final String certificateId;

  @override
  State<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  final repository = CertificateRepository();

  Certificate? certificate;
  bool isLoading = true;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final certificates = await repository.getMyCertificates();
      final match = certificates
          .where((c) => c.id == widget.certificateId)
          .toList();
      if (!mounted) return;
      setState(() {
        certificate = match.isNotEmpty ? match.first : null;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> generatePdf() async {
    setState(() => isGenerating = true);
    try {
      final updated = await repository.generatePdf(widget.certificateId);
      if (!mounted) return;
      setState(() {
        certificate = updated;
        isGenerating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).generatePdfError)),
      );
    }
  }

  Future<void> openPdf() async {
    final url = certificate?.pdfUrl;
    if (url == null) return;
    final uri = Uri.parse(AppConfig.resolveUrl(url));
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 2, itemHeight: 160),
              );
            }

            final cert = certificate;
            if (cert == null) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    EmptyState(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AppColors.secondary,
                      title: l10n.certificateNotFoundTitle,
                      message: l10n.certificateNotFoundMessage,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GradientHeroCard(
                    gradient: AppGradients.gold,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.certificateOfCompletion,
                          style: AppTypography.h2.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          cert.courseTitle,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _levelLabel(l10n, cert.level),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          label: l10n.certificateCodeLabel,
                          value: cert.certificateCode,
                        ),
                        const Divider(height: AppSpacing.xl),
                        _InfoRow(
                          label: l10n.issuedOnLabel,
                          value: DateFormat.yMMMMd().format(cert.issuedAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (cert.pdfUrl == null)
                    PrimaryButton(
                      label: l10n.generatePdfButton,
                      icon: Icons.picture_as_pdf,
                      isLoading: isGenerating,
                      onPressed: generatePdf,
                    )
                  else
                    PrimaryButton(
                      label: l10n.viewDownloadPdfButton,
                      icon: Icons.download,
                      onPressed: openPdf,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTypography.caption),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTypography.title.copyWith(fontSize: 15),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
