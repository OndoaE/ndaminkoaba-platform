import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
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
import '../data/book_bookmarks_repository.dart';
import '../data/bookmarks_repository.dart';
import '../domain/bookmarked_book.dart';
import '../domain/bookmarked_lesson.dart';

/// "Favoris" sidebar screen — lists lessons and books the learner
/// bookmarked, in two labeled sections. Lessons are backed by
/// `GET /bookmarks?userId=`; books by the separate `GET /book-bookmarks?
/// userId=` (see `BookBookmark` on the backend for why books get their own
/// model instead of a nullable-FK overload of the lesson Bookmark table).
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final lessonRepository = BookmarksRepository();
  final bookRepository = BookBookmarksRepository();

  bool isLoading = true;
  List<BookmarkedLesson> lessonBookmarks = [];
  List<BookmarkedBook> bookBookmarks = [];

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
      final results = await Future.wait([
        lessonRepository.getAll(userId: userId),
        bookRepository.getAll(userId: userId),
      ]);
      if (!mounted) return;
      setState(() {
        lessonBookmarks = results[0] as List<BookmarkedLesson>;
        bookBookmarks = results[1] as List<BookmarkedBook>;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeLesson(BookmarkedLesson bookmark) async {
    try {
      await lessonRepository.remove(bookmark.bookmarkId);
      if (!mounted) return;
      setState(() => lessonBookmarks.removeWhere((b) => b.bookmarkId == bookmark.bookmarkId));
    } catch (_) {
      // Best-effort — the row simply stays if the delete failed.
    }
  }

  Future<void> _removeBook(BookmarkedBook bookmark) async {
    try {
      await bookRepository.remove(bookmark.bookmarkId);
      if (!mounted) return;
      setState(() => bookBookmarks.removeWhere((b) => b.bookmarkId == bookmark.bookmarkId));
    } catch (_) {
      // Best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEmpty = lessonBookmarks.isEmpty && bookBookmarks.isEmpty;

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
                : isEmpty
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
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        children: [
                          if (lessonBookmarks.isNotEmpty) ...[
                            Text(l10n.learnerFavoritesLessonsSection, style: AppTypography.title.copyWith(fontSize: 15)),
                            const SizedBox(height: AppSpacing.md),
                            for (final bookmark in lessonBookmarks)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _LessonRow(bookmark: bookmark, onRemove: () => _removeLesson(bookmark)),
                              ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          if (bookBookmarks.isNotEmpty) ...[
                            Text(l10n.learnerFavoritesBooksSection, style: AppTypography.title.copyWith(fontSize: 15)),
                            const SizedBox(height: AppSpacing.md),
                            for (final bookmark in bookBookmarks)
                              Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: _BookRow(bookmark: bookmark, onRemove: () => _removeBook(bookmark)),
                              ),
                          ],
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.bookmark, required this.onRemove});

  final BookmarkedLesson bookmark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
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
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.bookmark, required this.onRemove});

  final BookmarkedBook bookmark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.large,
      onTap: () => context.push('/books/${bookmark.bookId}'),
      child: PremiumCard(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.medium,
              child: bookmark.coverUrl != null
                  ? Image.network(
                      AppConfig.resolveUrl(bookmark.coverUrl!),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _fallback(),
                    )
                  : SizedBox(width: 44, height: 44, child: _fallback()),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                bookmark.bookTitle,
                style: AppTypography.title.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.secondary, size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.secondary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: const Icon(Icons.auto_stories_outlined, color: AppColors.secondary),
    );
  }
}
