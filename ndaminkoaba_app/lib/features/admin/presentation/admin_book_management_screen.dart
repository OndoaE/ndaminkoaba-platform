import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../config/app_config.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/navigation/admin_shell.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../data/book_repository.dart';
import '../domain/book_models.dart';

const _bookAccent = [Color(0xFF5D4037), Color(0xFF8D6E63)];

class AdminBookManagementScreen extends StatefulWidget {
  const AdminBookManagementScreen({
    super.key,
    required this.languageId,
    this.languageName,
  });

  final String languageId;
  final String? languageName;

  @override
  State<AdminBookManagementScreen> createState() =>
      _AdminBookManagementScreenState();
}

class _AdminBookManagementScreenState extends State<AdminBookManagementScreen> {
  final repository = BookRepository();
  final searchController = TextEditingController();
  List<AdminBook> books = [];
  bool isLoading = true;
  String? error;
  String? categoryFilter;

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
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await repository.getBooks(languageId: widget.languageId);
      setState(() {
        books = result;
        isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        error = extractErrorMessage(e, fallback: 'Could not load books.');
        isLoading = false;
      });
    }
  }

  List<AdminBook> get _visible {
    final query = searchController.text.trim().toLowerCase();
    return books.where((book) {
      final matchesCategory = categoryFilter == null || book.category == categoryFilter;
      final matchesSearch = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          (book.author?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> addBook() async {
    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Book'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, titleController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    titleController.dispose();
    if (title == null || title.isEmpty) return;

    try {
      final bookId = await repository.createBook(title: title, languageId: widget.languageId);
      if (!mounted) return;
      // Land straight in the full editor so category/level/reading-time/
      // cover/content (file or pages) can be filled in right after
      // creation — mirrors the Lesson Management redirect pattern.
      context.pushReplacement('/admin/books/$bookId/edit', extra: title);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not add book.'));
    }
  }

  void editBook(AdminBook book) {
    context.push('/admin/books/${book.id}/edit', extra: book.title).then((_) => load());
  }

  Future<void> deleteBook(AdminBook book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('"${book.title}" will be removed for every learner.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repository.deleteBook(book.id);
      load();
      _showMessage('Book deleted.');
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: 'Could not delete book.'));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.languageName ?? 'Language';
    final visible = _visible;
    return AdminShell(
      activeNavKey: 'books',
      languageId: widget.languageId,
      languageName: title,
      title: 'Book Management',
      subtitle: 'Books for $title',
      actions: [
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _bookAccent[0]),
          onPressed: addBook,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Book'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search books',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: categoryFilter == null,
                  onTap: () => setState(() => categoryFilter = null),
                ),
                for (final category in kBookCategories)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _CategoryChip(
                      label: bookCategoryLabel(category),
                      selected: categoryFilter == category,
                      onTap: () => setState(() => categoryFilter = category),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isLoading)
            const ShimmerListLoader(itemCount: 5, itemHeight: 88)
          else if (error != null)
            EmptyState(
              icon: Icons.error_outline,
              title: 'Something went wrong',
              message: error,
            )
          else if (visible.isEmpty)
            const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No books yet',
              message: 'Tap "Add Book" to create the first one.',
            )
          else
            Column(
              children: visible.map((book) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    borderRadius: AppRadius.medium,
                    onTap: () => editBook(book),
                    child: PremiumCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          _BookCover(book: book),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (book.author != null &&
                                    book.author!.isNotEmpty)
                                  Text(
                                    book.author!,
                                    style: AppTypography.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  children: [
                                    _Pill(
                                      label: book.fileType != null
                                          ? book.fileType!.toUpperCase()
                                          : (book.pageCount != null
                                              ? '${book.pageCount} pages'
                                              : 'No content yet'),
                                    ),
                                    if (book.category != null)
                                      _Pill(label: bookCategoryLabel(book.category!)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') editBook(book);
                              if (value == 'delete') deleteBook(book);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: _bookAccent[0],
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _bookAccent[0].withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: _bookAccent[0],
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});

  final AdminBook book;

  @override
  Widget build(BuildContext context) {
    final isPdf = book.fileType == 'pdf';
    final isPages = book.fileType == null && (book.pageCount ?? 0) > 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: book.coverUrl != null
          ? Image.network(
              AppConfig.resolveUrl(book.coverUrl!),
              width: 48,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _fallbackIcon(isPdf, isPages),
            )
          : SizedBox(width: 48, height: 64, child: _fallbackIcon(isPdf, isPages)),
    );
  }

  Widget _fallbackIcon(bool isPdf, bool isPages) {
    return Container(
      color: _bookAccent[0].withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        isPages
            ? Icons.auto_stories_outlined
            : (isPdf ? Icons.picture_as_pdf_outlined : Icons.menu_book_outlined),
        color: _bookAccent[0],
      ),
    );
  }
}
