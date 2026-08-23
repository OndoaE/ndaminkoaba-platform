import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/app_config.dart';
import '../../../core/language/learning_language_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/learner_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/app_header.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookmarks/data/book_bookmarks_repository.dart';
import '../data/book_progress_repository.dart';
import '../data/book_repository.dart';
import '../domain/book.dart';

const _bookAccent = Color(0xFF5D4037);

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  final repository = BookRepository();
  final progressRepository = BookProgressRepository();
  final bookmarksRepository = BookBookmarksRepository();

  bool isLoading = true;
  bool hasError = false;
  List<Book> books = [];
  Book? selectedBook;
  String? categoryFilter;
  String searchQuery = '';
  String? userId;
  Map<String, BookProgressEntry> progressByBookId = {};
  String? selectedBookmarkId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final fetchedUserId = await StorageService.getUserId();
      final results = await Future.wait([
        repository.getBooks(languageId: ref.read(currentLearningLanguageProvider)),
        if (fetchedUserId != null) progressRepository.getAllForUser(fetchedUserId),
      ]);
      if (!mounted) return;
      final fetchedBooks = results[0] as List<Book>;
      setState(() {
        books = fetchedBooks;
        userId = fetchedUserId;
        if (fetchedUserId != null) {
          progressByBookId = {
            for (final p in results[1] as List<BookProgressEntry>) p.bookId: p,
          };
        }
        selectedBook = fetchedBooks.isNotEmpty ? fetchedBooks.first : null;
        isLoading = false;
      });
      if (selectedBook != null) _refreshBookmarkState();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _refreshBookmarkState() async {
    final book = selectedBook;
    final currentUserId = userId;
    if (book == null || currentUserId == null) {
      setState(() => selectedBookmarkId = null);
      return;
    }
    try {
      final id = await bookmarksRepository.findBookmarkId(userId: currentUserId, bookId: book.id);
      if (!mounted) return;
      setState(() => selectedBookmarkId = id);
    } catch (_) {
      // Favorite state is a nice-to-have — leave the button in its
      // default (not-favorited) state rather than blocking the screen.
    }
  }

  Future<void> _toggleFavorite() async {
    final book = selectedBook;
    final currentUserId = userId;
    if (book == null || currentUserId == null) return;
    try {
      if (selectedBookmarkId != null) {
        await bookmarksRepository.remove(selectedBookmarkId!);
        setState(() => selectedBookmarkId = null);
      } else {
        final id = await bookmarksRepository.create(userId: currentUserId, bookId: book.id);
        setState(() => selectedBookmarkId = id);
      }
    } catch (_) {
      // Best-effort — silently leave state unchanged on failure.
    }
  }

  List<Book> get _visible {
    final query = searchQuery.trim().toLowerCase();
    return books.where((book) {
      final matchesCategory = categoryFilter == null || book.category == categoryFilter;
      final matchesSearch = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          (book.author?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _selectBook(Book book) {
    setState(() => selectedBook = book);
    _refreshBookmarkState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LearnerShell(
      activeNavKey: 'library',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: ShimmerListLoader(itemCount: 4, itemHeight: 96),
                )
              : hasError
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: EmptyState(
                        icon: Icons.wifi_off_outlined,
                        iconColor: AppColors.error,
                        title: l10n.commonSomethingWrong,
                        action: PrimaryButton(label: l10n.commonRetry, onPressed: load),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppHeader(title: l10n.booksTitle, subtitle: l10n.booksSubtitle),
                          const SizedBox(height: AppSpacing.lg),
                          TextField(
                            decoration: InputDecoration(
                              hintText: l10n.booksHubSearchHint,
                              prefixIcon: const Icon(Icons.search),
                            ),
                            onChanged: (v) => setState(() => searchQuery = v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _CategoryPill(
                                  label: l10n.booksHubCategoryAll,
                                  selected: categoryFilter == null,
                                  onTap: () => setState(() => categoryFilter = null),
                                ),
                                for (final category in kBookCategories)
                                  Padding(
                                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                                    child: _CategoryPill(
                                      label: bookCategoryLabel(category),
                                      selected: categoryFilter == category,
                                      onTap: () => setState(() => categoryFilter = category),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Expanded(
                            child: books.isEmpty
                                ? EmptyState(
                                    icon: Icons.menu_book_outlined,
                                    iconColor: _bookAccent,
                                    title: l10n.noBooksTitle,
                                    message: l10n.noBooksMessage,
                                    lottieAsset: 'assets/lottie/books_stack.json',
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      final grid = _BookGrid(
                                        books: _visible,
                                        selectedBookId: selectedBook?.id,
                                        progressByBookId: progressByBookId,
                                        onSelect: _selectBook,
                                      );
                                      final detail = _DetailPane(
                                        book: selectedBook,
                                        isFavorited: selectedBookmarkId != null,
                                        onToggleFavorite: userId == null ? null : _toggleFavorite,
                                        onRead: selectedBook == null
                                            ? null
                                            : () => context.push('/books/${selectedBook!.id}'),
                                      );

                                      if (constraints.maxWidth >= 760) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(flex: 3, child: grid),
                                            const SizedBox(width: AppSpacing.lg),
                                            SizedBox(width: 320, child: detail),
                                          ],
                                        );
                                      }

                                      return SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [grid, const SizedBox(height: AppSpacing.lg), detail],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      shape: const StadiumBorder(),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({
    required this.books,
    required this.selectedBookId,
    required this.progressByBookId,
    required this.onSelect,
  });

  final List<Book> books;
  final String? selectedBookId;
  final Map<String, BookProgressEntry> progressByBookId;
  final ValueChanged<Book> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (books.isEmpty) {
      return Text(l10n.booksHubSelectBookMessage, style: AppTypography.caption);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.66,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final progress = progressByBookId[book.id];
        final isNew = book.createdAt != null &&
            DateTime.now().difference(book.createdAt!).inDays < 14;
        return InkWell(
          borderRadius: AppRadius.medium,
          onTap: () => onSelect(book),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.medium,
              border: Border.all(
                color: book.id == selectedBookId ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 0.72,
                  child: ClipRRect(
                    borderRadius: AppRadius.small,
                    child: book.coverUrl != null
                        ? Image.network(
                            AppConfig.resolveUrl(book.coverUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => _fallbackCover(book),
                          )
                        : _fallbackCover(book),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  book.title,
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.category != null)
                  Text(bookCategoryLabel(book.category!), style: AppTypography.caption.copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                if (progress != null && !progress.completed && book.pageCount != null && book.pageCount! > 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress.lastPageNumber / book.pageCount!,
                      minHeight: 4,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                else if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: AppRadius.circle,
                    ),
                    child: Text(
                      l10n.booksHubNewBadge,
                      style: AppTypography.caption.copyWith(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackCover(Book book) {
    final isPdf = book.fileType == 'pdf';
    return Container(
      color: _bookAccent.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        book.isPagesMode
            ? Icons.auto_stories_outlined
            : (isPdf ? Icons.picture_as_pdf_outlined : Icons.menu_book_outlined),
        color: _bookAccent,
      ),
    );
  }
}

class _DetailPane extends StatelessWidget {
  const _DetailPane({
    required this.book,
    required this.isFavorited,
    required this.onToggleFavorite,
    required this.onRead,
  });

  final Book? book;
  final bool isFavorited;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = book;

    if (current == null) {
      return Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.large),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(l10n.booksHubSelectBookMessage, style: AppTypography.caption),
      );
    }

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.large),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (current.coverUrl != null)
              ClipRRect(
                borderRadius: AppRadius.medium,
                child: Image.network(
                  AppConfig.resolveUrl(current.coverUrl!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(current.title, style: AppTypography.h2),
            if (current.author != null && current.author!.isNotEmpty)
              Text(current.author!, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.md),
            if (current.description != null && current.description!.isNotEmpty) ...[
              Text(current.description!, style: AppTypography.body),
              const SizedBox(height: AppSpacing.md),
            ],
            if (current.category != null)
              _MetaRow(label: l10n.booksHubCategoryLabel, value: bookCategoryLabel(current.category!)),
            if (current.level != null) _MetaRow(label: l10n.booksHubLevelLabel, value: current.level!),
            if (current.languageName != null)
              _MetaRow(label: l10n.booksHubLanguageLabel, value: current.languageName!),
            if (current.pageCount != null)
              _MetaRow(label: l10n.booksHubPagesLabel, value: '${current.pageCount}'),
            if (current.createdAt != null)
              _MetaRow(label: l10n.booksHubPublishedLabel, value: DateFormat.yMMMd().format(current.createdAt!)),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: l10n.booksHubReadButton, onPressed: onRead),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onToggleFavorite,
              icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, size: 16),
              label: Text(isFavorited ? l10n.booksHubRemoveFromFavoritesButton : l10n.booksHubAddToFavoritesButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: AppTypography.caption)),
          Expanded(
            child: Text(
              value,
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
