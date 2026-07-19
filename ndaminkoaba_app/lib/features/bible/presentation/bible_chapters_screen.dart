import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/bible_repository.dart';
import '../domain/models/bible_verse.dart';

/// Chapter picker for a book with more than one chapter uploaded — reached
/// from [BibleBooksScreen] (skipped entirely when a book only has one
/// chapter, which jumps straight to the reader).
class BibleChaptersScreen extends ConsumerStatefulWidget {
  const BibleChaptersScreen({super.key, required this.book, this.displayName});

  /// The exact `book` string as stored on the backend (used for queries).
  final String book;

  /// Locale-appropriate label to show in the UI, if known already.
  final String? displayName;

  @override
  ConsumerState<BibleChaptersScreen> createState() => _BibleChaptersScreenState();
}

class _BibleChaptersScreenState extends ConsumerState<BibleChaptersScreen> {
  final repository = BibleRepository();

  bool isLoading = true;
  List<BibleChapterInfo> chapters = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => isLoading = true);
    try {
      final all = await repository.getChapters(
        languageId: ref.read(currentLearningLanguageProvider),
      );
      final gospel = matchGospelBook(widget.book);
      final filtered = gospel != null
          ? consolidatedChaptersForGospel(all, gospel)
          : (all.where((c) => c.book == widget.book).toList()
            ..sort((a, b) => a.chapter.compareTo(b.chapter)));

      if (!mounted) return;
      setState(() {
        chapters = filtered;
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
    final title = widget.displayName ?? widget.book;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 3, itemHeight: 64),
              )
            : chapters.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: EmptyState(
                      icon: Icons.menu_book_outlined,
                      iconColor: const Color(0xFF8B3A3A),
                      title: l10n.bibleNoContentTitle,
                      message: l10n.bibleNoContentMessage,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.bibleSelectChapterTitle, style: AppTypography.title),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: AppSpacing.sm,
                              mainAxisSpacing: AppSpacing.sm,
                              childAspectRatio: 1,
                            ),
                            itemCount: chapters.length,
                            itemBuilder: (context, index) {
                              final info = chapters[index];
                              return InkWell(
                                borderRadius: AppRadius.medium,
                                onTap: () => context.push(
                                  '/bible/${Uri.encodeComponent(info.book)}/${info.chapter}',
                                  extra: title,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: AppRadius.medium,
                                    border: Border.all(color: AppColors.divider),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${info.chapter}',
                                        style: AppTypography.title.copyWith(
                                          color: const Color(0xFF8B3A3A),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.bibleVerseCountLabel(info.verseCount),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
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
