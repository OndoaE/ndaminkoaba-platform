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
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
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
        error = extractErrorMessage(e, fallback: l10n.adminBookMgmtLoadError);
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
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.adminBookMgmtAddBook),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.adminBookMgmtTitleLabel),
            onSubmitted: (v) => Navigator.pop(context, v.trim()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.adminBookMgmtCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(context, titleController.text.trim()),
              child: Text(l10n.adminBookMgmtCreate),
            ),
          ],
        );
      },
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
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookMgmtAddError));
    }
  }

  void editBook(AdminBook book) {
    context.push('/admin/books/${book.id}/edit', extra: book.title).then((_) => load());
  }

  Future<void> deleteBook(AdminBook book) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.adminBookMgmtDeleteTitle),
          content: Text(l10n.adminBookMgmtDeleteBody(book.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.adminBookMgmtCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n.adminBookMgmtDelete,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    try {
      await repository.deleteBook(book.id);
      load();
      _showMessage(l10n.adminBookMgmtDeletedMessage);
    } on DioException catch (e) {
      _showMessage(extractErrorMessage(e, fallback: l10n.adminBookMgmtDeleteError));
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
    final l10n = AppLocalizations.of(context);
    final title = widget.languageName ?? l10n.adminBookMgmtLanguageFallback;
    final visible = _visible;
    return AdminShell(
      activeNavKey: 'books',
      languageId: widget.languageId,
      languageName: title,
      title: l10n.adminBookMgmtTitle,
      subtitle: l10n.adminBookMgmtSubtitle(title),
      actions: [
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _bookAccent[0]),
          onPressed: addBook,
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.adminBookMgmtAddBook),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: l10n.adminBookMgmtSearchLabel,
              prefixIcon: const Icon(Icons.search),
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
                  label: l10n.adminBookMgmtCategoryAll,
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
              title: l10n.adminBookMgmtErrorTitle,
              message: error,
            )
          else if (visible.isEmpty)
            EmptyState(
              icon: Icons.menu_book_outlined,
              title: l10n.adminBookMgmtEmptyTitle,
              message: l10n.adminBookMgmtEmptyMessage,
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
                                              ? l10n.adminBookMgmtPagesCount(book.pageCount!)
                                              : l10n.adminBookMgmtNoContent),
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
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Text(l10n.adminBookMgmtEdit)),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(l10n.adminBookMgmtDelete),
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
