class BibleVerse {
  final String id;
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String? englishText;
  final String? frenchText;
  final String version;

  const BibleVerse({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    this.englishText,
    this.frenchText,
    required this.version,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      id: json['id'] ?? '',
      book: json['book'] ?? '',
      chapter: json['chapter'] ?? 0,
      verse: json['verse'] ?? 0,
      text: json['text'] ?? '',
      englishText: json['englishText'],
      frenchText: json['frenchText'],
      version: json['version'] ?? 'ESV',
    );
  }
}

class BibleChapterInfo {
  final String book;
  final int chapter;
  final String version;
  final int verseCount;

  const BibleChapterInfo({
    required this.book,
    required this.chapter,
    required this.version,
    required this.verseCount,
  });

  factory BibleChapterInfo.fromJson(Map<String, dynamic> json) {
    return BibleChapterInfo(
      book: json['book'] ?? '',
      chapter: json['chapter'] ?? 0,
      version: json['version'] ?? 'ESV',
      verseCount: json['verseCount'] ?? 0,
    );
  }
}

/// The four Gospels get spotlighted on the Bible home screen. Admins enter
/// book names as free text (and the seeded data already has a typo —
/// "Mathew" instead of "Matthew"), so recognizing a saved book as one of
/// the Gospels is done via a small alias list rather than an exact string
/// match, which would silently fail to show real content.
enum GospelBook { matthew, mark, luke, john }

extension GospelBookInfo on GospelBook {
  String get displayNameEn => switch (this) {
        GospelBook.matthew => 'Matthew',
        GospelBook.mark => 'Mark',
        GospelBook.luke => 'Luke',
        GospelBook.john => 'John',
      };

  String get displayNameFr => switch (this) {
        GospelBook.matthew => 'Matthieu',
        GospelBook.mark => 'Marc',
        GospelBook.luke => 'Luc',
        GospelBook.john => 'Jean',
      };

  List<String> get _aliases => switch (this) {
        GospelBook.matthew => ['matthew', 'mathew', 'matt', 'mat', 'mt', 'matthieu', 'mateus'],
        GospelBook.mark => ['mark', 'mrk', 'mk', 'marc', 'markus'],
        GospelBook.luke => ['luke', 'luk', 'lk', 'luc', 'lukas'],
        GospelBook.john => ['john', 'jhn', 'jn', 'jean', 'yoannes', 'yoane'],
      };
}

/// Returns the [GospelBook] a saved `book` value refers to, or null if it
/// isn't recognized as one of the four Gospels.
GospelBook? matchGospelBook(String bookName) {
  final normalized = bookName.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  for (final gospel in GospelBook.values) {
    if (gospel._aliases.contains(normalized)) return gospel;
  }
  return null;
}

/// Different USFM uploads for the same Gospel can arrive under different
/// free-text book-name spellings (e.g. an old single test chapter saved as
/// "Mathew" alongside a later full-book upload saved as "Mateus"). This
/// picks one chapter list for the Gospel: whichever book-name variant has
/// the most chapters uploaded "wins" for any chapter number it provides,
/// so the learner never sees the same chapter number listed twice.
List<BibleChapterInfo> consolidatedChaptersForGospel(
  List<BibleChapterInfo> allChapters,
  GospelBook gospel,
) {
  final matches = allChapters.where((c) => matchGospelBook(c.book) == gospel).toList();
  if (matches.isEmpty) return const [];

  final countByBook = <String, int>{};
  for (final c in matches) {
    countByBook[c.book] = (countByBook[c.book] ?? 0) + 1;
  }
  final booksLeastToMostPreferred = countByBook.keys.toList()
    ..sort((a, b) => countByBook[a]!.compareTo(countByBook[b]!));

  final byChapter = <int, BibleChapterInfo>{};
  for (final book in booksLeastToMostPreferred) {
    for (final c in matches.where((m) => m.book == book)) {
      byChapter[c.chapter] = c;
    }
  }
  final result = byChapter.values.toList()..sort((a, b) => a.chapter.compareTo(b.chapter));
  return result;
}
