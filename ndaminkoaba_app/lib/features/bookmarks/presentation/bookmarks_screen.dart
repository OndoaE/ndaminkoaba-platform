import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import '../data/bookmarks_repository.dart';
import '../domain/bookmarked_lesson.dart';

/// "Favoris" sidebar screen — lists lessons the learner bookmarked, backed
/// by the already-working `GET /bookmarks?userId=` (see
/// `bookmarks.controller.ts`); no new backend endpoint needed, only the
/// nested `lesson.module.course` include added to `bookmarks.service.ts`
/// so each row can navigate straight to its lesson.
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final repository = BookmarksRepository();

  bool isLoading = true;
  List<BookmarkedLesson> bookmarks = [];

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
        bookmarks = items;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _remove(BookmarkedLesson bookmark) async {
    try {
      await repository.remove(bookmark.bookmarkId);
      if (!mounted) return;
      setState(() => bookmarks.removeWhere((b) => b.bookmarkId == bookmark.bookmarkId));
    } catch (_) {
      // Best-effort — the row simply stays if the delete failed.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LearnerShell(
      activeNavKey: 'favorites',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(l10n.learnerNavFavorites, style: AppTypography.title),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: load,
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: ShimmerListLoader(itemCount: 4, itemHeight: 76),
                  )
                : bookmarks.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        children: [
                          EmptyState(
                            icon: Icons.bookmark_outline,
                            title: l10n.learnerNavFavorites,
                            message: l10n.learnerFavoritesEmptyMessage,
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: bookmarks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final bookmark = bookmarks[index];
                          return InkWell(
                            borderRadius: AppRadius.large,
                            onTap: () => context.push('/courses/${bookmark.courseId}/lessons/${bookmark.lessonId}'),
                            child: PremiumCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.15),
                                      borderRadius: AppRadius.medium,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.menu_book, color: AppColors.secondary),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bookmark.lessonTitle,
                                          style: AppTypography.title.copyWith(fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          bookmark.courseTitle,
                                          style: AppTypography.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark, color: AppColors.secondary, size: 20),
                                    onPressed: () => _remove(bookmark),
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
