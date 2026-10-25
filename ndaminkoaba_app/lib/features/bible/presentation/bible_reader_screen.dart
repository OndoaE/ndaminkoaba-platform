import 'dart:async';

import 'package:ndaminkoaba_app/design_system/widgets/nda_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../../config/app_config.dart';
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
import '../../../design_system/widgets/page_width.dart';

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
  final audioPlayer = AudioPlayer();

  bool isLoading = true;
  bool hasError = false;
  List<BibleVerse> verses = [];
  String? currentAudioUrl;

  /// True when the chapter has narration but the file could not be loaded
  /// (unreachable server, timeout). The bar then offers a retry instead of a
  /// play button that silently does nothing.
  bool audioFailed = false;
  StreamSubscription<ProcessingState>? _completionSub;

  /// Every chapter belonging to this book's Gospel (or exact book match for
  /// non-Gospels), deduped across free-text book-name variants so Previous/
  /// Next always resolves the correct `book` string per chapter number.
  List<BibleChapterInfo> availableChapters = [];

  @override
  void initState() {
    super.initState();
    // just_audio leaves `playing == true` when a clip finishes, so the button
    // would keep showing "pause" and could never replay. Reset to the start
    // and stop, so the button flips back to "play".
    _completionSub = audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        audioPlayer.pause();
        audioPlayer.seek(Duration.zero);
      }
    });
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
    // Stop whichever chapter's audio was playing before — never let it keep
    // playing under the newly-loading chapter's content.
    await audioPlayer.stop();
    if (mounted) setState(() => audioFailed = false);
    try {
      final languageId = ref.read(currentLearningLanguageProvider);
      final results = await Future.wait([
        repository.getVerses(
          book: widget.book,
          chapter: widget.chapter,
          languageId: languageId,
        ),
        repository.getChapters(languageId: languageId),
        repository.getChapterAudio(languageId: languageId),
      ]);
      final fetchedVerses = (results[0] as List<BibleVerse>)
        ..sort((a, b) => a.verse.compareTo(b.verse));
      final allChapters = results[1] as List<BibleChapterInfo>;
      final allAudio = results[2] as List<BibleChapterAudio>;

      final gospel = matchGospelBook(widget.book);
      final relevantChapters = gospel != null
          ? consolidatedChaptersForGospel(allChapters, gospel)
          : (allChapters.where((c) => c.book == widget.book).toList()
              ..sort((a, b) => a.chapter.compareTo(b.chapter)));

      final matchingAudio = allAudio
          .where((a) => a.book == widget.book && a.chapter == widget.chapter)
          .firstOrNull;

      if (!mounted) return;
      setState(() {
        verses = fetchedVerses;
        availableChapters = relevantChapters;
        currentAudioUrl = matchingAudio?.audioUrl;
        isLoading = false;
        hasError = fetchedVerses.isEmpty;
      });
      if (matchingAudio != null) {
        await _loadAudio(matchingAudio.audioUrl);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  /// Loads the narration into the player. Failure (unreachable or slow server)
  /// is surfaced through [audioFailed] so the bar can offer a retry; it is
  /// never an error dialog, because the text is still perfectly readable.
  Future<void> _loadAudio(String relativeUrl) async {
    try {
      await audioPlayer
          .setUrl(AppConfig.resolveUrl(relativeUrl))
          .timeout(const Duration(seconds: 45));
      if (mounted && currentAudioUrl == relativeUrl) {
        setState(() => audioFailed = false);
      }
    } catch (_) {
      if (mounted && currentAudioUrl == relativeUrl) {
        setState(() => audioFailed = true);
      }
    }
  }

  Future<void> _retryAudio() async {
    final url = currentAudioUrl;
    if (url == null) return;
    setState(() => audioFailed = false);
    await _loadAudio(url);
  }

  void _goToChapter(BibleChapterInfo target) {
    context.pushReplacement(
      '/bible/${Uri.encodeComponent(target.book)}/${target.chapter}',
      extra: widget.displayName,
    );
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final isFrench = locale.languageCode == 'fr';
    final title = widget.displayName ?? widget.book;

    final currentIndex = availableChapters.indexWhere(
      (c) => c.chapter == widget.chapter,
    );
    final hasPrev = currentIndex > 0;
    final hasNext =
        currentIndex != -1 && currentIndex < availableChapters.length - 1;

    return NdaScaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              l10n.bibleChapterLabel(widget.chapter),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
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
                  if (currentAudioUrl != null)
                    _ChapterAudioBar(
                      audioPlayer: audioPlayer,
                      failed: audioFailed,
                      onRetry: _retryAudio,
                    ),
                  Expanded(
                    child: PageWidth(
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
                          child: OutlinedButton(
                            onPressed: hasPrev
                                ? () => _goToChapter(
                                    availableChapters[currentIndex - 1],
                                  )
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.scripture,
                              side: const BorderSide(
                                color: AppColors.scripture,
                              ),
                            ),
                            // Built by hand rather than OutlinedButton.icon:
                            // that constructor lays its label out with no
                            // Flexible/ellipsis, so a longer translation
                            // (e.g. French "Chapitre précédent") overflows
                            // the half-width button on a narrow phone.
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chevron_left),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    l10n.biblePreviousChapter,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: FilledButton(
                            onPressed: hasNext
                                ? () => _goToChapter(
                                    availableChapters[currentIndex + 1],
                                  )
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.scripture,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.bibleNextChapter,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
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
  const _VerseTile({
    required this.verse,
    required this.isFrench,
    required this.pendingLabel,
  });

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
              color: AppColors.scripture.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${verse.verse}',
              style: const TextStyle(
                color: AppColors.scripture,
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
                  style: AppTypography.body.copyWith(
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(height: 1, color: AppColors.divider),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  translation ?? pendingLabel,
                  style: AppTypography.caption.copyWith(
                    height: 1.4,
                    fontStyle: translation == null
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: translation == null
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
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

/// Play/pause, seek bar and elapsed-time label for the chapter's Ewondo audio
/// narration. The player itself is owned and pre-loaded by
/// [_BibleReaderScreenState]; this widget reflects its state, so navigating
/// chapters (which stops and reloads the player before this bar is built
/// again) never leaves a stale control on screen.
class _ChapterAudioBar extends StatefulWidget {
  const _ChapterAudioBar({
    required this.audioPlayer,
    required this.failed,
    required this.onRetry,
  });

  final AudioPlayer audioPlayer;
  final bool failed;
  final VoidCallback onRetry;

  @override
  State<_ChapterAudioBar> createState() => _ChapterAudioBarState();
}

class _ChapterAudioBarState extends State<_ChapterAudioBar> {
  /// Slider value (milliseconds) while the learner is dragging; null otherwise.
  double? _dragMs;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = widget.audioPlayer;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: widget.failed ? _buildFailed(l10n) : _buildPlayer(l10n, player),
    );
  }

  Widget _buildFailed(AppLocalizations l10n) {
    return InkWell(
      onTap: widget.onRetry,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.refresh, color: AppColors.scripture, size: 28),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(l10n.bibleAudioError, style: AppTypography.caption)),
        ],
      ),
    );
  }

  Widget _buildPlayer(AppLocalizations l10n, AudioPlayer player) {
    return Row(
      children: [
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final playing = state?.playing ?? false;
            final loading = state?.processingState == ProcessingState.loading ||
                state?.processingState == ProcessingState.buffering;
            if (loading) {
              // Shown while the file is being fetched or the stream has run
              // dry, so a slow connection looks like loading, not a dead button.
              return const SizedBox(
                width: 48,
                height: 48,
                child: Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.scripture,
                  ),
                ),
              );
            }
            return IconButton(
              icon: Icon(
                playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: AppColors.scripture,
                size: 32,
              ),
              tooltip: playing ? l10n.bibleAudioPause : l10n.bibleAudioPlay,
              onPressed: () => playing ? player.pause() : player.play(),
            );
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.bibleAudioLabel, style: AppTypography.caption),
              StreamBuilder<Duration?>(
                stream: player.durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? player.duration ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final maxMs = duration.inMilliseconds.toDouble();
                      final currentMs = (_dragMs ?? position.inMilliseconds.toDouble())
                          .clamp(0.0, maxMs > 0 ? maxMs : 1.0);
                      final shown = Duration(milliseconds: currentMs.round());
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              activeTrackColor: AppColors.scripture,
                              inactiveTrackColor: AppColors.divider,
                              thumbColor: AppColors.scripture,
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: currentMs,
                              min: 0,
                              max: maxMs > 0 ? maxMs : 1.0,
                              // Seeking needs a known duration; until the file
                              // has loaded the slider is shown but inert.
                              onChanged: maxMs > 0 ? (v) => setState(() => _dragMs = v) : null,
                              onChangeEnd: maxMs > 0
                                  ? (v) async {
                                      await player.seek(Duration(milliseconds: v.round()));
                                      if (mounted) setState(() => _dragMs = null);
                                    }
                                  : null,
                            ),
                          ),
                          Text(
                            '${_formatDuration(shown)} / ${_formatDuration(duration)}',
                            style: AppTypography.caption,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
