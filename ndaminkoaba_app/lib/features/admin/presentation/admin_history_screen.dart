import 'package:flutter/material.dart';

import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gradient_app_bar.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';

const _historyAccent = Color(0xFF4B5FBD);

const _entityFilters = [
  'Course',
  'Module',
  'Lesson',
  'Quiz',
  'Vocabulary',
  'Knowledge Text',
  'Bible Verses',
  'Daily Word',
  'Daily Verse',
  'User',
  'Announcement',
];

/// Read-only audit trail of every admin/teacher action across the shared
/// content pool — every admin sees every other admin's changes here, since
/// content itself (courses, vocabulary, daily words, etc.) is intentionally
/// shared platform-wide rather than siloed per admin account.
class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  final repository = AdminRepository();
  List<AuditLogEntry> entries = [];
  String? selectedEntity;
  int page = 1;
  int totalPages = 1;
  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await repository.getAuditLogs(entity: selectedEntity);
      setState(() {
        entries = result.items;
        page = result.page;
        totalPages = result.totalPages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Could not load history.';
        isLoading = false;
      });
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || page >= totalPages) return;
    setState(() => isLoadingMore = true);
    try {
      final result = await repository.getAuditLogs(page: page + 1, entity: selectedEntity);
      setState(() {
        entries = [...entries, ...result.items];
        page = result.page;
        totalPages = result.totalPages;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() => isLoadingMore = false);
    }
  }

  void selectEntity(String? entity) {
    setState(() => selectedEntity = entity);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'History', colors: [Color(0xFF2F3E9E), Color(0xFF4B5FBD)]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Every create, edit, and delete made by any admin or teacher, '
                'newest first — content is shared platform-wide, so this is how '
                'you see who did what.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: selectedEntity == null,
                        onSelected: (_) => selectEntity(null),
                        selectedColor: _historyAccent,
                        labelStyle: TextStyle(
                          color: selectedEntity == null ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    for (final entity in _entityFilters)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(entity),
                          selected: selectedEntity == entity,
                          onSelected: (_) => selectEntity(entity),
                          selectedColor: _historyAccent,
                          labelStyle: TextStyle(
                            color: selectedEntity == entity ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const ShimmerListLoader(itemCount: 6, itemHeight: 76)
                    : error != null
                        ? EmptyState(icon: Icons.error_outline, title: 'Something went wrong', message: error)
                        : entries.isEmpty
                            ? const EmptyState(
                                icon: Icons.history,
                                title: 'No activity yet',
                                message: 'Actions taken by admins and teachers will show up here.',
                              )
                            : ListView.separated(
                                itemCount: entries.length + (page < totalPages ? 1 : 0),
                                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  if (index == entries.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      child: Center(
                                        child: isLoadingMore
                                            ? const CircularProgressIndicator()
                                            : TextButton(onPressed: loadMore, child: const Text('Load more')),
                                      ),
                                    );
                                  }
                                  return _AuditLogTile(entry: entries[index]);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  const _AuditLogTile({required this.entry});

  final AuditLogEntry entry;

  (IconData, Color) get _actionIcon {
    switch (entry.action) {
      case 'CREATE':
        return (Icons.add_circle_outline, const Color(0xFF1B8A4A));
      case 'DELETE':
        return (Icons.remove_circle_outline, const Color(0xFFB33A3A));
      default:
        return (Icons.edit_outlined, const Color(0xFFC77B2E));
    }
  }

  String get _actionVerb {
    switch (entry.action) {
      case 'CREATE':
        return 'created';
      case 'DELETE':
        return 'deleted';
      case 'UPDATE':
        return 'updated';
      default:
        return entry.action.toLowerCase();
    }
  }

  String get _relativeTime {
    final diff = DateTime.now().difference(entry.createdAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _actionIcon;

    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                    children: [
                      TextSpan(text: entry.actorName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: ' $_actionVerb ${entry.entity.toLowerCase()}'),
                      if (entry.summary != null && entry.summary!.isNotEmpty)
                        TextSpan(
                          text: ' "${entry.summary}"',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.actorEmail} • $_relativeTime',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
