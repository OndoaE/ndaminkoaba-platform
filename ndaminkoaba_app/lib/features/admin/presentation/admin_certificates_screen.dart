import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/level_stars.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../features/certificates/domain/certificate_theme.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

class AdminCertificatesScreen extends StatefulWidget {
  const AdminCertificatesScreen({super.key});

  @override
  State<AdminCertificatesScreen> createState() =>
      _AdminCertificatesScreenState();
}

class _AdminCertificatesScreenState extends State<AdminCertificatesScreen> {
  final repository = AdminRepository();

  bool isLoading = true;
  List<AdminCertificate> certificates = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final result = await repository.getCertificates();
      if (!mounted) return;
      setState(() {
        certificates = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeNavKey: 'certificates',
      title: 'Issued Certificates',
      subtitle: '${certificates.length} total',
      child: isLoading
          ? const ShimmerListLoader()
          : certificates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_outlined, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: AppSpacing.md),
                      Text('No certificates issued yet.', style: AppTypography.caption),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: certificates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final cert = certificates[index];
                    final theme = certificateThemeForLevel(cert.level);
                    return PremiumCard(
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: theme.gradient,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.workspace_premium, color: Colors.white),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(cert.learnerName, style: AppTypography.title)),
                                    LevelStars(count: theme.starCount, size: 13),
                                  ],
                                ),
                                Text(cert.courseTitle, style: AppTypography.caption),
                                Text(
                                  '${cert.certificateCode} • ${DateFormat.yMMMd().format(cert.issuedAt)}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
