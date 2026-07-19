import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../config/app_config.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/book_repository.dart';
import '../domain/book.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _bookAccent,
        foregroundColor: Colors.white,
        title: FutureBuilder<Book>(
          future: bookFuture,
          builder: (context, snapshot) => Text(
            snapshot.data?.title ?? l10n.booksTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: FutureBuilder<Book>(
        future: bookFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.bookLoadError));
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _bookAccent),
            );
          }

          final book = snapshot.data!;

          return book.fileType == 'epub'
              ? _EpubReader(url: AppConfig.resolveUrl(book.fileUrl))
              : _PdfReader(fileUrl: book.fileUrl);
        },
      ),
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
