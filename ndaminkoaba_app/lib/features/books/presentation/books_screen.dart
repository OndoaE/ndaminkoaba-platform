import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../core/language/learning_language_provider.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
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

  late Future<List<Book>> booksFuture;

  @override
  void initState() {
    super.initState();
    booksFuture = repository.getBooks(languageId: ref.read(currentLearningLanguageProvider));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
          future: booksFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 4, itemHeight: 96),
              );
            }

            final books = snapshot.data!;
            final l10n = AppLocalizations.of(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.booksTitle,
                    style: AppTypography.h1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.booksSubtitle,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (books.isEmpty)
                    EmptyState(
                      icon: Icons.menu_book_outlined,
                      iconColor: _bookAccent,
                      title: l10n.noBooksTitle,
                      message: l10n.noBooksMessage,
                    )
                  else
                    ...books.map(
                      (book) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => context.push('/books/${book.id}'),
                          child: _BookCard(book: book),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final isPdf = book.fileType == 'pdf';

    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.medium,
            child: book.coverUrl != null
                ? Image.network(
                    AppConfig.resolveUrl(book.coverUrl!),
                    width: 56,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        _fallbackCover(isPdf),
                  )
                : SizedBox(width: 56, height: 76, child: _fallbackCover(isPdf)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: AppTypography.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.author != null && book.author!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    book.author!,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (book.description != null && book.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    book.description!,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _bookAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    book.fileType.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: _bookAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _fallbackCover(bool isPdf) {
    return Container(
      color: _bookAccent.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        isPdf ? Icons.picture_as_pdf_outlined : Icons.menu_book_outlined,
        color: _bookAccent,
      ),
    );
  }
}
