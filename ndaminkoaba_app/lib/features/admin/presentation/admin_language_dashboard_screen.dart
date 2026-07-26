import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../domain/admin_models.dart';

/// A single language's admin dashboard — structurally the same screen every
/// language gets (stats, workflow, content quality, quick actions), just
/// scoped to [languageId]. Reached by tapping a language card on the Global
/// Dashboard or the Languages management list. A brand-new, empty language
/// lands here with zero special-casing: the same Quick Actions the admin
/// already knows from every other language, just building against an empty
/// content set.
class AdminLanguageDashboardScreen extends StatefulWidget {
  const AdminLanguageDashboardScreen({
    super.key,
    required this.languageId,
    this.languageName,
  });

  final String languageId;
  final String? languageName;

  @override
  State<AdminLanguageDashboardScreen> createState() => _AdminLanguageDashboardScreenState();
}

class _AdminLanguageDashboardScreenState extends State<AdminLanguageDashboardScreen> {
  final repository = AdminRepository();

  bool isLoading = true;
  AdminStats? stats;
  List<AdminCourse> courses = [];
  ({int draft, int inReview, int approved, int published})? workflow;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        repository.getStats(languageId: widget.languageId),
        repository.getCourses(languageId: widget.languageId),
        repository.getContentWorkflow(languageId: widget.languageId),
      ]);
      if (!mounted) return;
      setState(() {
        stats = results[0] as AdminStats;
        courses = results[1] as List<AdminCourse>;
        workflow = results[2] as ({int draft, int inReview, int approved, int published});
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
    final title = widget.languageName ?? l10n.adminLanguageFallback;
    final totalLessons = (workflow == null)
        ? 0
        : workflow!.draft + workflow!.inReview + workflow!.approved + workflow!.published;
    final readyPercent = totalLessons == 0
        ? 0
        : (((workflow!.approved + workflow!.published) / totalLessons) * 100).round();

    return AdminShell(
      activeNavKey: 'dashboard',
      languageId: widget.languageId,
      languageName: title,
      title: l10n.adminLanguageDashboardTitle(title),
      subtitle: l10n.adminLanguageDashboardSubtitle(title),
      actions: [
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () async {
            await context.push('/admin/languages/${widget.languageId}/courses/new');
            load();
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.adminNewCourseButton),
        ),
      ],
      child: isLoading
          ? const ShimmerListLoader(itemCount: 5, itemHeight: 100)
          : RefreshIndicator(
              onRefresh: load,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.menu_book,
                          value: '${stats?.courses ?? 0}',
                          label: l10n.adminColCourses,
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.play_lesson,
                          value: '${stats?.lessons ?? 0}',
                          label: l10n.adminStatLessons,
                          iconColor: const Color(0xFF0D7A4C),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.translate,
                          value: '${stats?.vocabulary ?? 0}',
                          label: l10n.adminNavVocabulary,
                          iconColor: AppColors.ai,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.workspace_premium,
                          value: '${stats?.certificates ?? 0}',
                          label: l10n.adminNavCertificates,
                          iconColor: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.adminCourseManagementTitle, style: AppTypography.title),
                      OutlinedButton(
                        onPressed: () => context.push(
                          '/admin/languages/${widget.languageId}/courses',
                          extra: title,
                        ),
                        child: Text(l10n.adminViewAllCourses),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AdminDataTable(
                    columns: [
                      AdminTableColumn(l10n.adminColCourseSingle, flex: 2),
                      AdminTableColumn(l10n.adminColLevel),
                      AdminTableColumn(l10n.adminColStatus),
                    ],
                    rows: courses.take(5).map((course) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(course.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                          Expanded(child: Text(course.level)),
                          Expanded(child: StatusPill(status: course.status)),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.adminContentWorkflowTitle, style: AppTypography.title.copyWith(fontSize: 15)),
                                const SizedBox(height: AppSpacing.md),
                                _WorkflowRow(label: l10n.adminWorkflowDraft, count: workflow?.draft ?? 0, total: totalLessons, color: AppColors.secondary),
                                _WorkflowRow(label: l10n.adminWorkflowInReview, count: workflow?.inReview ?? 0, total: totalLessons, color: AppColors.ai),
                                _WorkflowRow(label: l10n.adminWorkflowApproved, count: workflow?.approved ?? 0, total: totalLessons, color: const Color(0xFF0E8C7C)),
                                _WorkflowRow(label: l10n.adminWorkflowPublished, count: workflow?.published ?? 0, total: totalLessons, color: AppColors.success),
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
                                Text(l10n.adminContentQualityTitle, style: AppTypography.title.copyWith(fontSize: 15)),
                                const SizedBox(height: AppSpacing.lg),
                                SegmentedDonut(
                                  overallPercent: readyPercent,
                                  segments: [
                                    DonutSegment(label: l10n.adminWorkflowPublished, percent: workflow?.published ?? 0, color: AppColors.success),
                                    DonutSegment(label: l10n.adminWorkflowApproved, percent: workflow?.approved ?? 0, color: const Color(0xFF0E8C7C)),
                                    DonutSegment(label: l10n.adminWorkflowInReview, percent: workflow?.inReview ?? 0, color: AppColors.ai),
                                    DonutSegment(label: l10n.adminWorkflowDraft, percent: workflow?.draft ?? 0, color: AppColors.secondary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: _QuickActionsPanel(languageId: widget.languageId, onChanged: load)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.adminRecentCertificatesTitle, style: AppTypography.title.copyWith(fontSize: 15)),
                                const SizedBox(height: AppSpacing.md),
                                if (stats == null || stats!.recentCertificates.isEmpty)
                                  Text(l10n.adminNoCertificatesYet, style: AppTypography.caption)
                                else
                                  ...stats!.recentCertificates.map(
                                    (c) => Padding(
                                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.workspace_premium, color: AppColors.secondary, size: 18),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: Text(
                                              l10n.adminCertificateCompletedLine(c.learnerName, c.courseTitle),
                                              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(DateFormat.yMMMd().format(c.issuedAt), style: AppTypography.caption.copyWith(fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: FeaturedCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.auto_awesome, color: AppColors.secondary),
                                const SizedBox(height: AppSpacing.sm),
                                Text(l10n.adminNnangaAiReviewTitle, style: AppTypography.title.copyWith(fontSize: 15)),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l10n.adminNnangaReviewCountMessage(stats?.aiReviewCount ?? 0, title),
                                  style: AppTypography.caption,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                  onPressed: () => context.push(
                                    '/admin/languages/${widget.languageId}/courses',
                                    extra: title,
                                  ),
                                  child: Text(l10n.adminReviewContentButton),
                                ),
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

class _WorkflowRow extends StatelessWidget {
  const _WorkflowRow({required this.label, required this.count, required this.total, required this.color});

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: 76, child: Text(label, style: AppTypography.caption)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 20, child: Text('$count', textAlign: TextAlign.end, style: AppTypography.caption)),
        ],
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel({required this.languageId, required this.onChanged});

  final String languageId;
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
          _QuickActionTile(
            icon: Icons.play_lesson_outlined,
            label: l10n.adminQuickActionNewLesson,
            onTap: () async {
              await context.push('/admin/languages/$languageId/lessons/new');
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickActionTile(
            icon: Icons.quiz_outlined,
            label: l10n.adminQuickActionNewQuiz,
            onTap: () async {
              await context.push('/admin/languages/$languageId/quizzes/new');
              onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _QuickActionTile(
            icon: Icons.psychology_outlined,
            label: l10n.adminQuickActionTrainAi,
            onTap: () async {
              await context.push('/admin/languages/$languageId/knowledge');
              onChanged();
            },
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: AppRadius.small),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
