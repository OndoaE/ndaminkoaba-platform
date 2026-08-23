import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../config/app_config.dart';
import '../../../core/services/storage_service.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/radius/app_radius.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../design_system/typography/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookmarks/data/book_bookmarks_repository.dart';
import '../data/book_progress_repository.dart';
import '../data/book_repository.dart';
import '../domain/book.dart';
import '../domain/book_page.dart';

const _bookAccent = Color(0xFF5D4037);

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final repository = BookRepository();

  late Future<Book> bookFuture;

  @override
  void initState() {
    super.initState();
    bookFuture = repository.getBook(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Book>(
      future: bookFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: _bookAccent, foregroundColor: Colors.white),
            body: Center(child: Text(l10n.bookLoadError)),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: _bookAccent)),
          );
        }

        final book = snapshot.data!;

        // Pages-mode books get the new custom illustrated reader — it owns
        // its own Scaffold/app bar (text-size/audio/bookmark controls).
        // File-mode books keep the existing embedded viewers completely
        // unchanged: zero regression risk to books that don't opt into
        // pages.
        if (book.isPagesMode) {
          return _IllustratedBookReader(book: book);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: _bookAccent,
            foregroundColor: Colors.white,
            title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          body: book.fileType == 'epub'
              ? _EpubReader(url: AppConfig.resolveUrl(book.fileUrl!))
              : _PdfReader(fileUrl: book.fileUrl!),
        );
      },
    );
  }
}

class _PdfReader extends StatefulWidget {
  const _PdfReader({required this.fileUrl});

  final String fileUrl;

  @override
  State<_PdfReader> createState() => _PdfReaderState();
}

class _PdfReaderState extends State<_PdfReader> {
  final repository = BookRepository();

  late Future<Uint8List> bytesFuture;
  bool isRendering = true;
  String? renderError;

  @override
  void initState() {
    super.initState();
    bytesFuture = repository.downloadBookFile(widget.fileUrl);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Uint8List>(
      future: bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${l10n.bookLoadError}\n${snapshot.error}', textAlign: TextAlign.center));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: _bookAccent));
        }

        return Stack(
          children: [
            SfPdfViewer.memory(
              snapshot.data!,
              onDocumentLoaded: (_) => setState(() => isRendering = false),
              onDocumentLoadFailed: (details) => setState(() {
                isRendering = false;
                renderError = details.description;
              }),
            ),
            if (isRendering)
              const Center(
                child: CircularProgressIndicator(color: _bookAccent),
              ),
            if (renderError != null)
              Container(
                color: AppColors.background,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${l10n.bookLoadError}\n$renderError',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EpubReader extends StatefulWidget {
  const _EpubReader({required this.url});

  final String url;

  @override
  State<_EpubReader> createState() => _EpubReaderState();
}

class _EpubReaderState extends State<_EpubReader> {
  final epubController = EpubController();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EpubViewer(
          epubController: epubController,
          epubSource: EpubSource.fromUrl(widget.url),
          onEpubLoaded: () => setState(() => isLoading = false),
        ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(color: _bookAccent),
          ),
      ],
    );
  }
}

const _kFontScales = [1.0, 1.15, 1.3];

/// The new page-by-page reader for admin-authored illustrated books —
/// illustration + original Ewondo text + French translation per page,
/// with page-flip controls, a page slider, text-size/audio/bookmark
/// controls, and reading-position persistence. Two-page spread on wide
/// layouts, single page on narrow ones.
class _IllustratedBookReader extends StatefulWidget {
  const _IllustratedBookReader({required this.book});

  final Book book;

  @override
  State<_IllustratedBookReader> createState() => _IllustratedBookReaderState();
}

class _IllustratedBookReaderState extends State<_IllustratedBookReader> {
  final repository = BookRepository();
  final progressRepository = BookProgressRepository();
  final bookmarksRepository = BookBookmarksRepository();
  final audioPlayer = AudioPlayer();

  bool isLoading = true;
  List<BookPage> pages = [];
  int currentIndex = 0;
  int fontScaleIndex = 0;
  bool isAudioPlaying = false;
  String? userId;
  String? bookmarkId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final fetchedUserId = await StorageService.getUserId();
      final results = await Future.wait([
        repository.getPages(widget.book.id),
        if (fetchedUserId != null)
          progressRepository.getProgress(userId: fetchedUserId, bookId: widget.book.id),
        if (fetchedUserId != null)
          bookmarksRepository.findBookmarkId(userId: fetchedUserId, bookId: widget.book.id),
      ]);
      if (!mounted) return;
      final fetchedPages = results[0] as List<BookPage>;
      final progress = fetchedUserId != null ? results[1] as BookProgressEntry? : null;
      final startIndex = (progress != null && !progress.completed && progress.lastPageNumber >= 1)
          ? (progress.lastPageNumber - 1).clamp(0, fetchedPages.isEmpty ? 0 : fetchedPages.length - 1)
          : 0;
      setState(() {
        pages = fetchedPages;
        userId = fetchedUserId;
        bookmarkId = fetchedUserId != null ? results[2] as String? : null;
        currentIndex = startIndex;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _recordProgress() {
    final currentUserId = userId;
    if (currentUserId == null) return;
    // Best-effort — a failed record must never block reading.
    progressRepository
        .recordProgress(userId: currentUserId, bookId: widget.book.id, lastPageNumber: currentIndex + 1)
        .catchError((_) {});
  }

  void _goToPage(int index) {
    if (index < 0 || index >= pages.length) return;
    setState(() {
      currentIndex = index;
      isAudioPlaying = false;
    });
    audioPlayer.stop();
    _recordProgress();
  }

  void _cycleFontScale() {
    setState(() => fontScaleIndex = (fontScaleIndex + 1) % _kFontScales.length);
  }

  Future<void> _toggleAudio() async {
    final audioUrl = pages[currentIndex].audioUrl;
    if (audioUrl == null) return;
    if (isAudioPlaying) {
      await audioPlayer.pause();
      setState(() => isAudioPlaying = false);
      return;
    }
    try {
      await audioPlayer.setUrl(AppConfig.resolveUrl(audioUrl));
      await audioPlayer.play();
      setState(() => isAudioPlaying = true);
    } catch (_) {
      setState(() => isAudioPlaying = false);
    }
  }

  Future<void> _toggleBookmark() async {
    final currentUserId = userId;
    if (currentUserId == null) return;
    try {
      if (bookmarkId != null) {
        await bookmarksRepository.remove(bookmarkId!);
        setState(() => bookmarkId = null);
      } else {
        final id = await bookmarksRepository.create(userId: currentUserId, bookId: widget.book.id);
        setState(() => bookmarkId = id);
      }
    } catch (_) {
      // Best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _bookAccent,
        foregroundColor: Colors.white,
        title: Text(widget.book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Text('Aa', style: TextStyle(fontWeight: FontWeight.w700)),
            tooltip: 'Text size',
            onPressed: _cycleFontScale,
          ),
          if (pages.isNotEmpty && pages[currentIndex].audioUrl != null)
            IconButton(
              icon: Icon(isAudioPlaying ? Icons.pause : Icons.volume_up_outlined),
              onPressed: _toggleAudio,
            ),
          IconButton(
            icon: Icon(bookmarkId != null ? Icons.bookmark : Icons.bookmark_border),
            onPressed: userId == null ? null : _toggleBookmark,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: _bookAccent))
          : pages.isEmpty
              ? Center(child: Text(l10n.bookLoadError))
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 700;
                            if (wide && currentIndex + 1 < pages.length) {
                              return Row(
                                children: [
                                  Expanded(child: _PageView(page: pages[currentIndex], fontScale: _kFontScales[fontScaleIndex])),
                                  const VerticalDivider(width: 1),
                                  Expanded(child: _PageView(page: pages[currentIndex + 1], fontScale: _kFontScales[fontScaleIndex])),
                                ],
                              );
                            }
                            return _PageView(page: pages[currentIndex], fontScale: _kFontScales[fontScaleIndex]);
                          },
                        ),
                      ),
                      _buildControls(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildControls() {
    final total = pages.length;
    final wide = MediaQuery.of(context).size.width >= 700;
    final spreadEnd = wide && currentIndex + 1 < total ? currentIndex + 2 : currentIndex + 1;
    final label = wide && currentIndex + 1 < total
        ? 'Page ${currentIndex + 1}-$spreadEnd / $total'
        : 'Page ${currentIndex + 1} / $total';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: currentIndex.toDouble(),
            min: 0,
            max: (total - 1).toDouble().clamp(0, double.infinity),
            divisions: total > 1 ? total - 1 : null,
            activeColor: _bookAccent,
            onChanged: (v) => _goToPage(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentIndex == 0 ? null : () => _goToPage(currentIndex - 1),
              ),
              Text(label, style: AppTypography.caption),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentIndex + 1 >= total ? null : () => _goToPage(currentIndex + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page, required this.fontScale});

  final BookPage page;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (page.illustrationUrl != null)
            ClipRRect(
              borderRadius: AppRadius.medium,
              child: Image.network(
                AppConfig.resolveUrl(page.illustrationUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.ewondoText,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: (AppTypography.body.fontSize ?? 15) * fontScale,
            ),
          ),
          if (page.frenchText != null && page.frenchText!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              page.frenchText!,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                fontSize: (AppTypography.caption.fontSize ?? 13) * fontScale,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
