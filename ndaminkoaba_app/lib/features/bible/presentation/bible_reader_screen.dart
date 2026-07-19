import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/bible_repository.dart';
import '../domain/models/bible_verse.dart';

/// Bilingual reader: Ewondo alongside whichever of English/French the
/// learner has selected as their UI language — never both, per the product
/// requirement that an English-UI learner only sees English and a
/// French-UI learner only sees French.
class BibleReaderScreen extends ConsumerStatefulWidget {
  const BibleReaderScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.displayName,
  });

  /// The exact `book` string as stored on the backend (used for queries).
  final String book;
  final int chapter;
  final String? displayName;

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  final repository = BibleRepository();

  bool isLoading = true;
  bool hasError = false;
  List<BibleVerse> verses = [];

  /// Every chapter belonging to this book's Gospel (or exact book match for
  /// non-Gospels), deduped across free-text book-name variants so Previous/
  /// Next always resolves the correct `book` string per chapter number.
  List<BibleChapterInfo> availableChapters = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(covariant BibleReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book != widget.book || oldWidget.chapter != widget.chapter) {
      load();
    }
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final languageId = ref.read(currentLearningLanguageProvider);
      final results = await Future.wait([
        repository.getVerses(book: widget.book, chapter: widget.chapter, languageId: languageId),
        repository.getChapters(languageId: languageId),
      ]);
      final fetchedVerses = (results[0] as List<BibleVerse>)..sort((a, b) => a.verse.compareTo(b.verse));
      final allChapters = results[1] as List<BibleChapterInfo>;

      final gospel = matchGospelBook(widget.book);
      final relevantChapters = gospel != null
          ? consolidatedChaptersForGospel(allChapters, gospel)
          : (allChapters.where((c) => c.book == widget.book).toList()
            ..sort((a, b) => a.chapter.compareTo(b.chapter)));

      if (!mounted) return;
      setState(() {
        verses = fetchedVerses;
        availableChapters = relevantChapters;
        isLoading = false;
        hasError = fetchedVerses.isEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _goToChapter(BibleChapterInfo target) {
    context.pushReplacement(
      '/bible/${Uri.encodeComponent(target.book)}/${target.chapter}',
      extra: widget.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final isFrench = locale.languageCode == 'fr';
    final title = widget.displayName ?? widget.book;

    final currentIndex = availableChapters.indexWhere((c) => c.chapter == widget.chapter);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex != -1 && currentIndex < availableChapters.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              l10n.bibleChapterLabel(widget.chapter),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: ShimmerListLoader(itemCount: 4, itemHeight: 90),
              )
            : hasError || verses.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: EmptyState(
                      icon: Icons.error_outline,
                      iconColor: AppColors.error,
                      title: l10n.bibleChapterNotFoundTitle,
                      message: l10n.bibleChapterNotFoundMessage,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.lg,
                            AppSpacing.xl,
                            AppSpacing.xl,
                          ),
                          itemCount: verses.length,
                          itemBuilder: (context, index) => _VerseTile(
                            verse: verses[index],
                            isFrench: isFrench,
                            pendingLabel: l10n.bibleTranslationPending,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(top: BorderSide(color: AppColors.divider)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: hasPrev
                                    ? () => _goToChapter(availableChapters[currentIndex - 1])
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                                label: Text(l10n.biblePreviousChapter),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF8B3A3A),
                                  side: const BorderSide(color: Color(0xFF8B3A3A)),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: hasNext
                                    ? () => _goToChapter(availableChapters[currentIndex + 1])
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                                label: Text(l10n.bibleNextChapter),
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B3A3A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({required this.verse, required this.isFrench, required this.pendingLabel});

  final BibleVerse verse;
  final bool isFrench;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final translation = isFrench ? verse.frenchText : verse.englishText;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF8B3A3A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${verse.verse}',
              style: const TextStyle(
                color: Color(0xFF8B3A3A),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verse.text,
                  style: AppTypography.body.copyWith(height: 1.55, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  translation ?? pendingLabel,
                  style: AppTypography.caption.copyWith(
                    height: 1.4,
                    fontStyle: translation == null ? FontStyle.italic : FontStyle.normal,
                    color: translation == null ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
