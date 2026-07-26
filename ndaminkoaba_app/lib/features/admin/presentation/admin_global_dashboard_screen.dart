import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/cards/featured_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/admin_data_table.dart';
import '../../../design_system/widgets/admin_stat_card.dart';
import '../../../design_system/widgets/segmented_donut.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../design_system/widgets/status_pill.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';
import '../data/content_repository.dart';
import '../domain/admin_content_models.dart';
import '../domain/admin_models.dart';

/// The admin's landing screen — platform-wide, language-agnostic overview.
/// Every piece of learning content lives inside a specific language's own
/// dashboard (see [AdminLanguageDashboardScreen]); this screen is the index
/// of which languages exist, platform-wide stats, and the handful of truly
/// global actions (users, certificates, announcements, audit history).
class AdminGlobalDashboardScreen extends StatefulWidget {
  const AdminGlobalDashboardScreen({super.key});

  @override
  State<AdminGlobalDashboardScreen> createState() => _AdminGlobalDashboardScreenState();
}

class _AdminGlobalDashboardScreenState extends State<AdminGlobalDashboardScreen> {
  final adminRepository = AdminRepository();
  final contentRepository = ContentRepository();

  bool isLoading = true;
  AdminStats? stats;
  List<AdminLanguage> languages = [];
  List<AuditLogEntry> recentActivity = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        adminRepository.getStats(),
        contentRepository.getLanguages(includeStats: true),
        adminRepository.getAuditLogs(),
      ]);
      if (!mounted) return;
      setState(() {
        stats = results[0] as AdminStats;
        languages = results[1] as List<AdminLanguage>;
        recentActivity = (results[2] as ({List<AuditLogEntry> items, int page, int totalPages})).items;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _openAddLanguageDialog() async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final countryController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminAddLanguageButton),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.adminAddLanguageNameHint)),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: codeController, decoration: InputDecoration(labelText: l10n.adminAddLanguageCodeHint)),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: countryController, decoration: InputDecoration(labelText: l10n.adminAddLanguageCountryHint)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.commonAdd)),
        ],
      ),
    );

    if (confirmed != true) return;
    if (nameController.text.trim().isEmpty || codeController.text.trim().isEmpty) return;

    try {
      await contentRepository.createLanguage(
        name: nameController.text.trim(),
        code: codeController.text.trim(),
        country: countryController.text.trim(),
      );
      load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminLanguageAddedMessage)),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e, fallback: l10n.adminCouldNotAddLanguage))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdminShell(
      activeNavKey: 'overview',
      title: l10n.adminDashboardOverviewTitle,
      subtitle: l10n.adminDashboardOverviewSubtitle,
      child: isLoading
          ? const ShimmerListLoader(itemCount: 5, itemHeight: 100)
          : RefreshIndicator(
              onRefresh: load,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat row
                  Row(
                    children: [
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.language,
                          value: '${languages.length}',
                          label: l10n.adminStatActiveLanguages,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.people,
                          value: '${stats?.users ?? 0}',
                          label: l10n.adminStatTotalLearners,
                          iconColor: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.menu_book,
                          value: '${stats?.coursesByStatus['PUBLISHED'] ?? 0}',
                          label: l10n.adminStatPublishedCourses,
                          iconColor: const Color(0xFF0D7A4C),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.check_circle_outline,
                          value: '${stats?.lessonsCompleted ?? 0}',
                          label: l10n.adminStatLessonsCompleted,
                          iconColor: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Language Management
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.adminLanguageManagementTitle, style: AppTypography.title),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: _openAddLanguageDialog,
                            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(l10n.adminAddLanguageButton),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: () => context.push('/admin/languages'),
                            child: Text(l10n.adminViewAllLanguages),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AdminDataTable(
                    columns: [
                      AdminTableColumn(l10n.adminColLanguage, flex: 2),
                      AdminTableColumn(l10n.adminColCode),
                      AdminTableColumn(l10n.adminColLearners),
                      AdminTableColumn(l10n.adminColCourses),
                      AdminTableColumn(l10n.adminColProgress, flex: 2),
                      AdminTableColumn(l10n.adminColStatus),
                      AdminTableColumn(l10n.adminColActions, flex: 2),
                    ],
                    rows: languages.map((language) {
                      final progress = (language.avgProgress ?? 0) / 100;
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.language, size: 16, color: AppColors.primary),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: Text(language.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700))),
                              ],
                            ),
                          ),
                          Expanded(child: Text(language.code.toUpperCase())),
                          Expanded(child: Text('${language.learnerCount ?? 0}')),
                          Expanded(child: Text('${language.courseCount ?? 0}')),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: AppColors.divider,
                                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text('${language.avgProgress ?? 0}%', style: AppTypography.caption),
                              ],
                            ),
                          ),
                          Expanded(child: StatusPill(status: language.isActive ? 'ACTIVE' : 'DRAFT')),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  ),
                                  onPressed: () => context.push('/admin/languages/${language.id}', extra: language.name),
                                  child: Text(l10n.adminOpenDashboard, style: const TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Learner Activity | Course Completion | Quick Actions
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 2, child: _LearnerActivityCard(points: stats?.learnerActivity ?? [])),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.adminCourseCompletionTitle, style: AppTypography.title.copyWith(fontSize: 15)),
                                const SizedBox(height: AppSpacing.lg),
                                SegmentedDonut(
                                  overallPercent: stats?.avgCourseCompletion ?? 0,
                                  segments: [
                                    DonutSegment(label: l10n.adminLevelBeginner, percent: stats?.courseCompletionByLevel['BEGINNER'] ?? 0, color: AppColors.primary),
                                    DonutSegment(label: l10n.adminLevelIntermediate, percent: stats?.courseCompletionByLevel['INTERMEDIATE'] ?? 0, color: AppColors.secondary),
                                    DonutSegment(label: l10n.adminLevelAdvanced, percent: stats?.courseCompletionByLevel['ADVANCED'] ?? 0, color: AppColors.badgeLocked),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: _QuickActionsGrid(onChanged: load)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Recent Activity | AI Content Review | System Notice
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 2, child: _RecentActivityCard(entries: recentActivity)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: FeaturedCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.auto_awesome, color: AppColors.secondary),
                                const SizedBox(height: AppSpacing.sm),
                                Text(l10n.adminAiContentReviewTitle, style: AppTypography.title.copyWith(fontSize: 15)),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l10n.adminAiReviewCountMessage(stats?.aiReviewCount ?? 0),
                                  style: AppTypography.caption,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                  onPressed: () => context.push('/admin/history'),
                                  child: Text(l10n.adminReviewContentButton),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                                const SizedBox(height: AppSpacing.sm),
                                Text(l10n.adminSystemNoticeTitle, style: AppTypography.title.copyWith(fontSize: 15)),
                                const SizedBox(height: AppSpacing.xs),
                                Text(l10n.adminAllSystemsOperational, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
                                const SizedBox(height: AppSpacing.xs),
                                Text(l10n.adminLastUpdatedLabel(DateFormat.yMMMd().add_jm().format(DateTime.now())), style: AppTypography.caption),
                              ],
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
  }
}

class _LearnerActivityCard extends StatelessWidget {
  const _LearnerActivityCard({required this.points});

  final List<LearnerActivityPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxY = points
        .expand((p) => [p.newLearners, p.activeLearners])
        .fold<int>(1, (a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.adminLearnerActivityTitle, style: AppTypography.title.copyWith(fontSize: 15)),
              const Spacer(),
              _LegendDot(color: AppColors.secondary, label: l10n.adminLegendNewLearners),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(color: AppColors.primary, label: l10n.adminLegendActiveLearners),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 180,
            child: points.isEmpty
                ? Center(child: Text(l10n.adminNoActivityData, style: AppTypography.caption))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY + 1,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= points.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.xs),
                                child: Text(
                                  DateFormat.E().format(points[index].date),
                                  style: AppTypography.caption.copyWith(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].newLearners.toDouble())],
                          isCurved: true,
                          color: AppColors.secondary,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].activeLearners.toDouble())],
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminQuickActionsTitle, style: AppTypography.title.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.4,
            children: [
              _QuickActionTile(
                icon: Icons.menu_book_outlined,
                label: l10n.adminQuickActionCreateCourse,
                onTap: () => context.push('/admin/languages'),
              ),
              _QuickActionTile(
                icon: Icons.person_add_outlined,
                label: l10n.adminQuickActionAddUser,
                onTap: () async {
                  await context.push('/admin/users/new');
                  onChanged();
                },
              ),
              _QuickActionTile(
                icon: Icons.upload_file_outlined,
                label: l10n.adminQuickActionUploadContent,
                onTap: () => context.push('/admin/languages'),
              ),
              _QuickActionTile(
                icon: Icons.workspace_premium_outlined,
                label: l10n.adminNavCertificates,
                onTap: () => context.push('/admin/certificates'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.small,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: AppRadius.small,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: AppTypography.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.entries});
  final List<AuditLogEntry> entries;

  String _activityLine(AppLocalizations l10n, AuditLogEntry entry) {
    final verb = switch (entry.action.toUpperCase()) {
      'CREATE' => l10n.adminAuditVerbCreated,
      'UPDATE' => l10n.adminAuditVerbUpdated,
      'DELETE' => l10n.adminAuditVerbDeleted,
      _ => entry.action.toLowerCase(),
    };
    final line = l10n.adminAuditActivityLine(entry.actorName, verb, entry.entity);
    return entry.summary != null ? '$line: ${entry.summary}' : line;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminRecentActivityTitle, style: AppTypography.title.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.md),
          if (entries.isEmpty)
            Text(l10n.adminNoRecentActivity, style: AppTypography.caption)
          else
            ...entries.take(5).map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _activityLine(l10n, entry),
                            style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(DateFormat.Md().format(entry.createdAt), style: AppTypography.caption.copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push('/admin/history'),
              child: Text(l10n.adminViewAllActivity),
            ),
          ),
        ],
      ),
    );
  }
}
