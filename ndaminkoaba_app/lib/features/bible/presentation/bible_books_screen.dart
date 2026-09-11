import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/app_config.dart';
import '../../../core/language/learning_language_provider.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/gradients/app_gradients.dart';
import '../../../design_system/inputs/premium_textfield.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/shadows/app_shadows.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../design_system/buttons/primary_button.dart';
import '../../../design_system/widgets/empty_state.dart';
import '../../../design_system/widgets/gold_corner_pattern.dart';
import '../../../design_system/widgets/section_title.dart';
import '../../../design_system/widgets/shimmer_list_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../data/bible_repository.dart';
import '../domain/models/bible_verse.dart';

/// Entry point for the learner-facing Bible reader — a photo hero banner up
/// top, then the Four Gospels spotlighted (per the product ask), with any
/// other uploaded books below. Content language (Ewondo + the learner's
/// chosen UI language) is resolved once inside the reader, not here.
class BibleBooksScreen extends ConsumerStatefulWidget {
  const BibleBooksScreen({super.key});

  @override
  ConsumerState<BibleBooksScreen> createState() => _BibleBooksScreenState();
}

class _BibleBooksScreenState extends ConsumerState<BibleBooksScreen> {
  final repository = BibleRepository();
  final searchController = TextEditingController();

  bool isLoading = true;
  bool hasError = false;
  List<BibleChapterInfo> chapters = [];
  String? heroImageUrl;
  Map<String, String> coverByKey = {};
  String searchQuery = '';

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
      hasError = false;
    });
    try {
      final languageId = ref.read(currentLearningLanguageProvider);
      final results = await Future.wait([
        repository.getChapters(languageId: languageId),
        repository.getImages(languageId: languageId),
      ]);
      if (!mounted) return;
      final fetchedChapters = results[0] as List<BibleChapterInfo>;
      final images = results[1] as BibleImages;
      setState(() {
        chapters = fetchedChapters;
        heroImageUrl = images.hero?.imageUrl;
        coverByKey = {for (final cover in images.covers) cover.bookKey: cover.coverUrl};
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
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

  bool _matchesSearch(String title) {
    if (searchQuery.trim().isEmpty) return true;
    return title.toLowerCase().contains(searchQuery.trim().toLowerCase());
  }

  GospelBook? get _firstAvailableGospel {
    for (final gospel in GospelBook.values) {
      if (consolidatedChaptersForGospel(chapters, gospel).isNotEmpty) return gospel;
    }
    return null;
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

    final firstGospel = _firstAvailableGospel;
    VoidCallback? onStartReading;
    if (firstGospel != null) {
      onStartReading = () {
        final gospelChapters = consolidatedChaptersForGospel(chapters, firstGospel);
        final displayName = isFrench ? firstGospel.displayNameFr : firstGospel.displayNameEn;
        _openBook(gospelChapters.first.book, gospelChapters, displayName);
      };
    }

    final visibleGospels = GospelBook.values
        .where((gospel) => _matchesSearch(isFrench ? gospel.displayNameFr : gospel.displayNameEn))
        .toList();
    final visibleOtherBooks = _otherBooks.where(_matchesSearch).toList();

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
            : hasError
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: EmptyState(
                      icon: Icons.wifi_off_outlined,
                      iconColor: AppColors.error,
                      title: l10n.commonSomethingWrong,
                      action: PrimaryButton(
                        label: l10n.commonRetry,
                        onPressed: load,
                      ),
                    ),
                  )
                : chapters.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: EmptyState(
                      icon: Icons.menu_book_outlined,
                      iconColor: AppColors.scripture,
                      title: l10n.bibleNoContentTitle,
                      message: l10n.bibleNoContentMessage,
                      lottieAsset: 'assets/lottie/bible_open.json',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      _BibleHero(imageUrl: heroImageUrl, onStartReading: onStartReading),
                      const SizedBox(height: AppSpacing.xl),
                      PremiumTextField(
                        controller: searchController,
                        hint: l10n.bibleSearchHint,
                        prefixIcon: Icons.search,
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ChoiceChip(
                            label: Text(l10n.bibleLanguagePillEwondo),
                            selected: true,
                            onSelected: null,
                            selectedColor: AppColors.scripture,
                            showCheckmark: false,
                            shape: const StadiumBorder(),
                            labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          ChoiceChip(
                            label: Text(l10n.bibleLanguagePillFrench),
                            selected: isFrench,
                            onSelected: (_) => setAppLocale(ref, const Locale('fr')),
                            selectedColor: AppColors.scripture,
                            showCheckmark: false,
                            shape: StadiumBorder(
                              side: BorderSide(color: isFrench ? AppColors.scripture : Colors.black12),
                            ),
                            labelStyle: TextStyle(
                              color: isFrench ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ChoiceChip(
                            label: Text(l10n.bibleLanguagePillEnglish),
                            selected: !isFrench,
                            onSelected: (_) => setAppLocale(ref, const Locale('en')),
                            selectedColor: AppColors.scripture,
                            showCheckmark: false,
                            shape: StadiumBorder(
                              side: BorderSide(color: !isFrench ? AppColors.scripture : Colors.black12),
                            ),
                            labelStyle: TextStyle(
                              color: !isFrench ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (visibleGospels.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        SectionTitle(
                          title: l10n.bibleFourGospelsTitle,
                          subtitle: l10n.bibleFourGospelsSubtitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _BibleBookGrid(
                          cards: visibleGospels.map((gospel) {
                            final gospelChapters = consolidatedChaptersForGospel(chapters, gospel);
                            final displayName = isFrench ? gospel.displayNameFr : gospel.displayNameEn;

                            return _BibleBookCard(
                              title: displayName,
                              chapterCount: gospelChapters.length,
                              coverUrl: coverByKey[gospel.name.toUpperCase()],
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
                      ],
                      if (visibleOtherBooks.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        SectionTitle(title: l10n.bibleOtherBooksTitle),
                        const SizedBox(height: AppSpacing.md),
                        _BibleBookGrid(
                          cards: visibleOtherBooks.map((book) {
                            final bookChapters = chapters.where((c) => c.book == book).toList();
                            return _BibleBookCard(
                              title: book,
                              chapterCount: bookChapters.length,
                              coverUrl: coverByKey[book],
                              comingSoonLabel: l10n.bibleComingSoonLabel,
                              chaptersLabel: l10n.bibleChaptersCountLabel(bookChapters.length),
                              onTap: () => _openBook(book, bookChapters, book),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
      ),
    );
  }
}

class _BibleHero extends StatelessWidget {
  const _BibleHero({required this.imageUrl, required this.onStartReading});

  final String? imageUrl;
  final VoidCallback? onStartReading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadius.extraLarge,
        boxShadow: [
          BoxShadow(
            color: AppColors.scripture.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: hasImage
                ? Image.network(
                    AppConfig.resolveUrl(imageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const DecoratedBox(
                      decoration: BoxDecoration(gradient: AppGradients.scripture),
                    ),
                  )
                : const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppGradients.scripture),
                  ),
          ),
          if (!hasImage)
            const Positioned(
              right: -10,
              bottom: -10,
              child: Icon(Icons.auto_stories, size: 140, color: Colors.white24),
            ),
          if (hasImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.38)),
              ),
            ),
          const Positioned.fill(
            child: GoldCornerPattern(color: Colors.white, size: 72),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.bibleHeroEyebrow,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.bibleHeroHeadline,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.bibleHeroSubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (onStartReading != null)
                  FilledButton(
                    onPressed: onStartReading,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.scripture,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      shape: const StadiumBorder(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.bibleHeroCta,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
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

/// Adaptive-column grid shared by the Gospels section and the "Autres
/// livres" section — a fixed column count either cramps on a phone or stays
/// stuck small on a wide desktop-web window, so the count scales with
/// available width instead (still 2 on a phone).
class _BibleBookGrid extends StatelessWidget {
  const _BibleBookGrid({required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 200).floor().clamp(2, 4);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.78,
          children: cards,
        );
      },
    );
  }
}

class _BibleBookCard extends StatelessWidget {
  const _BibleBookCard({
    required this.title,
    required this.chapterCount,
    required this.coverUrl,
    required this.comingSoonLabel,
    required this.chaptersLabel,
    required this.onTap,
  });

  final String title;
  final int chapterCount;
  final String? coverUrl;
  final String comingSoonLabel;
  final String chaptersLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final available = onTap != null;
    final hasCover = coverUrl != null && coverUrl!.isNotEmpty;

    return Opacity(
      opacity: available ? 1 : 0.55,
      child: InkWell(
        borderRadius: AppRadius.large,
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasCover
                        ? Image.network(
                            AppConfig.resolveUrl(coverUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => const DecoratedBox(
                              decoration: BoxDecoration(gradient: AppGradients.scripture),
                            ),
                          )
                        : const DecoratedBox(
                            decoration: BoxDecoration(gradient: AppGradients.scripture),
                            child: Center(
                              child: Icon(Icons.menu_book, color: Colors.white54, size: 36),
                            ),
                          ),
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.scripture,
                          borderRadius: AppRadius.small,
                          boxShadow: AppShadows.soft,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.menu_book, color: Colors.white, size: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.title.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      available ? chaptersLabel : comingSoonLabel,
                      style: AppTypography.caption.copyWith(
                        color: available ? AppColors.scripture : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
