import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_error.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/admin_data_table.dart';
import '../../../design_system/widgets/admin_stat_card.dart';
import '../../../design_system/widgets/bulk_action_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../design_system/widgets/status_pill.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';
import '../data/content_repository.dart';
import '../domain/admin_models.dart';

const _levels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

class _StatusTab {
  const _StatusTab(this.key, this.label, this.status);
  final String key;
  final String label;
  final String? status;
}

List<_StatusTab> _statusTabs(AppLocalizations l10n) => [
      _StatusTab('all', l10n.adminTabAll, null),
      _StatusTab('published', l10n.adminWorkflowPublished, 'PUBLISHED'),
      _StatusTab('draft', l10n.adminStatDrafts, 'DRAFT'),
      _StatusTab('review', l10n.adminWorkflowInReview, 'IN_REVIEW'),
      _StatusTab('archived', l10n.adminWorkflowArchived, 'ARCHIVED'),
    ];

String _levelLabel(AppLocalizations l10n, String level) {
  return switch (level) {
    'BEGINNER' => l10n.adminLevelBeginner,
    'INTERMEDIATE' => l10n.adminLevelIntermediate,
    'ADVANCED' => l10n.adminLevelAdvanced,
    _ => level,
  };
}

/// Desktop Course Management screen — status-tab strip, a filterable/
/// selectable data table wired to the real bulk-status and reviewer-
/// assignment endpoints, and a right-hand sidebar of pipeline/health/
/// activity panels. Reached from a language's sidebar "Courses" item.
class AdminCourseManagementScreen extends StatefulWidget {
  const AdminCourseManagementScreen({super.key, required this.languageId, this.languageName});

  final String languageId;
  final String? languageName;

  @override
  State<AdminCourseManagementScreen> createState() => _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState extends State<AdminCourseManagementScreen> {
  final adminRepository = AdminRepository();
  final contentRepository = ContentRepository();
  final searchController = TextEditingController();

  bool isLoading = true;
  String statusTabKey = 'all';
  String? levelFilter;
  List<AdminCourse> courses = [];
  AdminStats? stats;
  List<AdminUser> reviewers = [];
  ({int draft, int inReview, int approved, int published})? workflow;
  List<AuditLogEntry> recentActivity = [];
  final Set<String> selectedIds = {};

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
    setState(() => isLoading = true);
    final l10n = AppLocalizations.of(context);
    final status = _statusTabs(l10n).firstWhere((t) => t.key == statusTabKey).status;
    try {
      final results = await Future.wait([
        adminRepository.getCourses(
          languageId: widget.languageId,
          status: status,
          level: levelFilter,
          search: searchController.text.trim(),
        ),
        adminRepository.getStats(languageId: widget.languageId),
        adminRepository.getUsers(),
        adminRepository.getContentWorkflow(languageId: widget.languageId),
        adminRepository.getAuditLogs(entity: 'Course'),
      ]);
      if (!mounted) return;
      setState(() {
        courses = results[0] as List<AdminCourse>;
        stats = results[1] as AdminStats;
        reviewers = (results[2] as List<AdminUser>)
            .where((u) => u.role == 'TEACHER' || u.role == 'ADMIN')
            .toList();
        workflow = results[3] as ({int draft, int inReview, int approved, int published});
        recentActivity = (results[4] as ({List<AuditLogEntry> items, int page, int totalPages})).items;
        selectedIds.clear();
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _bulkSetStatus(String status) async {
    final l10n = AppLocalizations.of(context);
    try {
      await adminRepository.bulkSetCourseStatus(selectedIds.toList(), status);
      _showMessage(l10n.adminUpdatedCountMessage(selectedIds.length));
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotUpdateCourses));
    }
  }

  Future<void> _bulkAssignReviewer() async {
    final l10n = AppLocalizations.of(context);
    final reviewerId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminAssignReviewerTitle),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.adminAssignReviewerPrompt(selectedIds.length), style: AppTypography.caption),
              const SizedBox(height: AppSpacing.md),
              for (final reviewer in reviewers)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(reviewer.fullName),
                  subtitle: Text(reviewer.role, style: AppTypography.caption),
                  onTap: () => Navigator.pop(context, reviewer.id),
                ),
              if (reviewers.isEmpty) Text(l10n.adminNoReviewersAvailable, style: AppTypography.caption),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        ],
      ),
    );
    if (reviewerId == null) return;

    try {
      for (final id in selectedIds) {
        await contentRepository.updateCourse(id, reviewerId: reviewerId);
      }
      _showMessage(l10n.adminReviewerAssignedMessage);
      load();
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminCouldNotAssignReviewer));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.languageName ?? l10n.adminLanguageFallback;

    return AdminShell(
      activeNavKey: 'courses',
      languageId: widget.languageId,
      languageName: title,
      title: l10n.adminCourseManagementTitle,
      subtitle: l10n.adminCourseManagementSubtitle(title),
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.menu_book,
                        value: '${stats?.coursesByStatus.values.fold<int>(0, (a, b) => a + b) ?? 0}',
                        label: l10n.adminStatTotalCourses,
                        iconColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.check_circle_outline,
                        value: '${stats?.coursesByStatus['PUBLISHED'] ?? 0}',
                        label: l10n.adminWorkflowPublished,
                        iconColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.rate_review_outlined,
                        value: '${stats?.coursesByStatus['IN_REVIEW'] ?? 0}',
                        label: l10n.adminWorkflowInReview,
                        iconColor: AppColors.ai,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AdminStatCard(
                        icon: Icons.edit_note_outlined,
                        value: '${stats?.coursesByStatus['DRAFT'] ?? 0}',
                        label: l10n.adminStatDrafts,
                        iconColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final tab in _statusTabs(l10n))
                      ChoiceChip(
                        label: Text(tab.label),
                        selected: statusTabKey == tab.key,
                        onSelected: (_) {
                          setState(() => statusTabKey = tab.key);
                          load();
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: statusTabKey == tab.key ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onSubmitted: (_) => load(),
                        decoration: InputDecoration(
                          hintText: l10n.adminSearchCoursesHint,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: AppRadius.medium, borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    DropdownButton<String?>(
                      value: levelFilter,
                      hint: Text(l10n.adminAllLevelsLabel),
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.adminAllLevelsLabel)),
                        for (final l in _levels)
                          DropdownMenuItem(value: l, child: Text(_levelLabel(l10n, l))),
                      ],
                      onChanged: (value) {
                        setState(() => levelFilter = value);
                        load();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                if (selectedIds.isNotEmpty) ...[
                  BulkActionBar(
                    selectedCount: selectedIds.length,
                    actions: [
                      OutlinedButton(onPressed: () => _bulkSetStatus('PUBLISHED'), child: Text(l10n.adminBulkPublish)),
                      OutlinedButton(onPressed: () => _bulkSetStatus('DRAFT'), child: Text(l10n.adminBulkMoveToDraft)),
                      OutlinedButton(onPressed: () => _bulkSetStatus('ARCHIVED'), child: Text(l10n.adminBulkArchive)),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: _bulkAssignReviewer,
                        child: Text(l10n.adminAssignReviewerTitle),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: AdminDataTable(
                        leadingWidth: 36,
                        columns: [
                          AdminTableColumn(l10n.adminColCourseSingle, flex: 3),
                          AdminTableColumn(l10n.adminColLevel),
                          AdminTableColumn(l10n.adminColLessons),
                          AdminTableColumn(l10n.adminColReviewer, flex: 2),
                          AdminTableColumn(l10n.adminColStatus),
                        ],
                        rows: courses.map((course) {
                          final selected = selectedIds.contains(course.id);
                          return InkWell(
                            onTap: () async {
                              await context.push(
                                '/admin/languages/${widget.languageId}/courses/${course.id}',
                                extra: title,
                              );
                              load();
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Checkbox(
                                    value: selected,
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          selectedIds.add(course.id);
                                        } else {
                                          selectedIds.remove(course.id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    course.title,
                                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(child: Text(_levelLabel(l10n, course.level))),
                                Expanded(child: Text('${course.lessonsCount}')),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    course.reviewerName ?? l10n.commonUnassigned,
                                    style: AppTypography.caption.copyWith(
                                      color: course.reviewerName == null ? AppColors.textSecondary : AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(child: StatusPill(status: course.status)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    SizedBox(
                      width: 260,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SidebarPanel(
                            title: l10n.adminPublishingPipelineTitle,
                            child: Column(
                              children: [
                                for (final entry in {
                                  l10n.adminWorkflowDraft: stats?.coursesByStatus['DRAFT'] ?? 0,
                                  l10n.adminWorkflowInReview: stats?.coursesByStatus['IN_REVIEW'] ?? 0,
                                  l10n.adminWorkflowPublished: stats?.coursesByStatus['PUBLISHED'] ?? 0,
                                  l10n.adminWorkflowArchived: stats?.coursesByStatus['ARCHIVED'] ?? 0,
                                }.entries)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(entry.key, style: AppTypography.caption)),
                                        Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SidebarPanel(
                            title: l10n.adminContentHealthTitle,
                            child: Column(
                              children: [
                                _healthRow(l10n.adminHealthLessonsPublished, workflow?.published ?? 0),
                                _healthRow(l10n.adminHealthLessonsApproved, workflow?.approved ?? 0),
                                _healthRow(l10n.adminHealthLessonsInReview, workflow?.inReview ?? 0),
                                _healthRow(l10n.adminHealthLessonsInDraft, workflow?.draft ?? 0),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _SidebarPanel(
                            title: l10n.adminRecentCourseActivityTitle,
                            child: recentActivity.isEmpty
                                ? Text(l10n.adminNoRecentActivity, style: AppTypography.caption)
                                : Column(
                                    children: recentActivity.take(5).map((entry) {
                                      final verb = switch (entry.action.toUpperCase()) {
                                        'CREATE' => l10n.adminAuditVerbCreated,
                                        'UPDATE' => l10n.adminAuditVerbUpdated,
                                        'DELETE' => l10n.adminAuditVerbDeleted,
                                        _ => entry.action.toLowerCase(),
                                      };
                                      final line = l10n.adminAuditActivityLine(entry.actorName, verb, l10n.adminColCourseSingle.toLowerCase());
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.summary != null ? '$line: ${entry.summary}' : line,
                                              style: AppTypography.caption.copyWith(color: AppColors.textPrimary, fontSize: 12),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(DateFormat.yMMMd().add_jm().format(entry.createdAt), style: AppTypography.caption.copyWith(fontSize: 10)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _healthRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.caption)),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SidebarPanel extends StatelessWidget {
  const _SidebarPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.title.copyWith(fontSize: 14)),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
