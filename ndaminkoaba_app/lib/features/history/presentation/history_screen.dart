import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/storage_service.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/learner_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/lesson_history_repository.dart';
import '../domain/lesson_view_entry.dart';

/// "Historique" sidebar screen — real backend-tracked lesson-view history
/// (Phase 1's `GET /lesson-history?userId=`), not a placeholder.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final repository = LessonHistoryRepository();

  bool isLoading = true;
  List<LessonViewEntry> entries = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    final userId = await StorageService.getUserId();
    if (userId == null) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }
    try {
      final items = await repository.getAll(userId: userId);
      if (!mounted) return;
      setState(() {
        entries = items;
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

    return LearnerShell(
      activeNavKey: 'history',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(l10n.learnerNavHistory, style: AppTypography.title),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: load,
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: ShimmerListLoader(itemCount: 4, itemHeight: 76),
                  )
                : entries.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        children: [
                          EmptyState(
                            icon: Icons.history_outlined,
                            title: l10n.learnerNavHistory,
                            message: l10n.learnerHistoryEmptyMessage,
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return InkWell(
                            borderRadius: AppRadius.large,
                            onTap: () => context.push('/courses/${entry.courseId}/lessons/${entry.lessonId}'),
                            child: PremiumCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: AppRadius.medium,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.history, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.lessonTitle,
                                          style: AppTypography.title.copyWith(fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          entry.courseTitle,
                                          style: AppTypography.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    l10n.learnerHistoryViewedOn(DateFormat.MMMd().format(entry.viewedAt)),
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
