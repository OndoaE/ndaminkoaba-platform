/// One parsed USFM chapter: its number and a verse-number → text map.
class UsfmChapter {
  const UsfmChapter({required this.chapter, required this.verses});

  final int chapter;
  final Map<int, String> verses;
}

class UsfmParseResult {
  const UsfmParseResult({this.bookCode, this.bookName, required this.chapters});

  final String? bookCode;
  final String? bookName;
  final List<UsfmChapter> chapters;

  int get verseCount => chapters.fold(0, (sum, c) => sum + c.verses.length);
}

/// Minimal USFM (Unified Standard Format Markers) reader — enough to pull a
/// whole book's chapter/verse text out of a raw Paratext-style export
/// without pulling in a full USFM library. Strips footnotes and cross
/// references, drops heading/title markers (they're not verse content), and
/// treats every other marker (paragraph/poetry/inline character styles like
/// \nd, \add) as a continuation of the verse currently open — which is what
/// lets multi-line poetry and inline styling still land in the right verse.
class UsfmParser {
  UsfmParser._();

  static const _skipMarkers = {
    'id', 'ide', 'sts', 'rem', 'usfm',
    'h', 'toc1', 'toc2', 'toc3',
    'mt', 'mt1', 'mt2', 'mt3', 'mte1', 'mte2',
    'imt', 'imt1', 'is', 'is1', 'is2', 'ip', 'iot', 'io', 'io1', 'io2',
    's', 's1', 's2', 's3', 's4', 'sp', 'sr', 'r', 'd', 'cl', 'cp', 'ca', 'va', 'vp',
    'periph', 'ie',
  };

  static final _footnotePattern = RegExp(r'\\f\b.*?\\f\*', dotAll: true);
  static final _crossRefPattern = RegExp(r'\\x\b.*?\\x\*', dotAll: true);
  static final _markerPattern = RegExp(r'\\([a-zA-Z0-9]+)\s?');
  static final _leadingNumber = RegExp(r'^(\d+)');

  static UsfmParseResult parse(String raw) {
    final cleaned = raw
        .replaceAll(_footnotePattern, '')
        .replaceAll(_crossRefPattern, '');

    final matches = _markerPattern.allMatches(cleaned).toList();

    String? bookCode;
    String? bookName;
    int? currentChapter;
    int? currentVerse;
    final buffer = StringBuffer();
    final chapters = <int, Map<int, String>>{};

    void flushVerse() {
      if (currentChapter != null && currentVerse != null) {
        final content = buffer.toString().trim();
        if (content.isNotEmpty) {
          final chapterVerses = chapters.putIfAbsent(currentChapter, () => {});
          chapterVerses[currentVerse] = content;
        }
      }
      buffer.clear();
    }

    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final marker = match.group(1)!;
      final contentStart = match.end;
      final contentEnd = i + 1 < matches.length ? matches[i + 1].start : cleaned.length;
      final content = cleaned.substring(contentStart, contentEnd).trim();

      switch (marker) {
        case 'id':
          bookCode = content.split(RegExp(r'\s+')).firstOrNull;
        case 'h':
        case 'mt1':
        case 'mt':
          if ((bookName == null || bookName.isEmpty) && content.isNotEmpty) {
            bookName = content;
          }
        case 'c':
          flushVerse();
          currentVerse = null;
          currentChapter = int.tryParse(_leadingNumber.firstMatch(content)?.group(1) ?? '');
        case 'v':
          flushVerse();
          final parts = content.split(RegExp(r'\s+'));
          currentVerse = parts.isEmpty
              ? null
              : int.tryParse(_leadingNumber.firstMatch(parts.first)?.group(1) ?? '');
          final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          buffer.write(rest);
        default:
          if (_skipMarkers.contains(marker)) {
            // Headings/titles/intros — not verse content, discard.
          } else if (currentVerse != null && content.isNotEmpty) {
            if (buffer.isNotEmpty) buffer.write(' ');
            buffer.write(content);
          }
      }
    }
    flushVerse();

    final orderedChapters = chapters.entries
        .map((entry) => UsfmChapter(chapter: entry.key, verses: entry.value))
        .toList()
      ..sort((a, b) => a.chapter.compareTo(b.chapter));

    return UsfmParseResult(bookCode: bookCode, bookName: bookName, chapters: orderedChapters);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
