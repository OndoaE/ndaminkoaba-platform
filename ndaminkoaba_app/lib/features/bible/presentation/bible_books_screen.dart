import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../design_system/cards/premium_card.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/bible_repository.dart';
import '../domain/models/bible_verse.dart';

/// Entry point for the learner-facing Bible reader — the Four Gospels are
/// spotlighted (per the product ask), with any other uploaded books listed
/// below. Content language (Ewondo + the learner's chosen UI language) is
/// resolved once inside the reader, not here.
class BibleBooksScreen extends ConsumerStatefulWidget {
  const BibleBooksScreen({super.key});

  @override
  ConsumerState<BibleBooksScreen> createState() => _BibleBooksScreenState();
}

class _BibleBooksScreenState extends ConsumerState<BibleBooksScreen> {
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
      final result = await repository.getChapters(
        languageId: ref.read(currentLearningLanguageProvider),
      );
      if (!mounted) return;
      setState(() {
        chapters = result;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  List<String> get _otherBooks {
    final others = <String>{};
    for (final c in chapters) {
      if (matchGospelBook(c.book) == null) others.add(c.book);
    }
    final list = others.toList()..sort();
    return list;
  }

  void _openBook(String book, List<BibleChapterInfo> bookChapters, String displayName) {
    if (bookChapters.length == 1) {
      context.push(
        '/bible/${Uri.encodeComponent(book)}/${bookChapters.first.chapter}',
        extra: displayName,
      );
    } else {
      context.push('/bible/${Uri.encodeComponent(book)}', extra: displayName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final isFrench = locale.languageCode == 'fr';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.bibleTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 4, itemHeight: 100),
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
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      _Header(subtitle: l10n.bibleSubtitle),
                      const SizedBox(height: AppSpacing.xl),
                      SectionTitle(
                        title: l10n.bibleFourGospelsTitle,
                        subtitle: l10n.bibleFourGospelsSubtitle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.9,
                        children: GospelBook.values.map((gospel) {
                          final gospelChapters = consolidatedChaptersForGospel(chapters, gospel);
                          final displayName = isFrench ? gospel.displayNameFr : gospel.displayNameEn;

                          return _GospelCard(
                            title: displayName,
                            chapterCount: gospelChapters.length,
                            comingSoonLabel: l10n.bibleComingSoonLabel,
                            chaptersLabel: l10n.bibleChaptersCountLabel(gospelChapters.length),
                            onTap: gospelChapters.isEmpty
                                ? null
                                : () => _openBook(
                                      gospelChapters.first.book,
                                      gospelChapters,
                                      displayName,
                                    ),
                          );
                        }).toList(),
                      ),
                      if (_otherBooks.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        SectionTitle(title: l10n.bibleOtherBooksTitle),
                        const SizedBox(height: AppSpacing.md),
                        ..._otherBooks.map((book) {
                          final bookChapters = chapters.where((c) => c.book == book).toList();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _BookRow(
                              title: book,
                              chaptersLabel: l10n.bibleChaptersCountLabel(bookChapters.length),
                              onTap: () => _openBook(book, bookChapters, book),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppGradients.scripture,
            borderRadius: AppRadius.medium,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B3A3A).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.auto_stories, color: Colors.white, size: 26),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(subtitle, style: AppTypography.caption.copyWith(height: 1.4)),
          ),
        ),
      ],
    );
  }
}

class _GospelCard extends StatelessWidget {
  const _GospelCard({
    required this.title,
    required this.chapterCount,
    required this.comingSoonLabel,
    required this.chaptersLabel,
    required this.onTap,
  });

  final String title;
  final int chapterCount;
  final String comingSoonLabel;
  final String chaptersLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final available = onTap != null;

    return Opacity(
      opacity: available ? 1 : 0.55,
      child: InkWell(
        borderRadius: AppRadius.large,
        onTap: onTap,
        child: PremiumCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: available
                      ? AppGradients.scripture
                      : const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFFD6D6D6)]),
                  borderRadius: AppRadius.medium,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.title.copyWith(fontSize: 15),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: available
                      ? const Color(0xFF8B3A3A).withValues(alpha: 0.1)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  available ? chaptersLabel : comingSoonLabel,
                  style: AppTypography.caption.copyWith(
                    color: available ? const Color(0xFF8B3A3A) : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.title, required this.chaptersLabel, required this.onTap});

  final String title;
  final String chaptersLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: PremiumCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B3A3A).withValues(alpha: 0.1),
                borderRadius: AppRadius.medium,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.menu_book_outlined, color: Color(0xFF8B3A3A), size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.title.copyWith(fontSize: 15)),
                  Text(chaptersLabel, style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
