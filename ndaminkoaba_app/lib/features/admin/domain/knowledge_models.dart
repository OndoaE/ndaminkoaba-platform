class KnowledgeWord {
  final String id;
  final String word;
  final String? englishMeaning;
  final String? frenchMeaning;
  final String? exampleSentence;
  final String? exampleTranslation;
  final String? frenchExampleTranslation;
  final String difficulty;
  final String? lessonId;

  const KnowledgeWord({
    required this.id,
    required this.word,
    this.englishMeaning,
    this.frenchMeaning,
    this.exampleSentence,
    this.exampleTranslation,
    this.frenchExampleTranslation,
    required this.difficulty,
    this.lessonId,
  });

  factory KnowledgeWord.fromJson(Map<String, dynamic> json) {
    return KnowledgeWord(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      englishMeaning: json['englishMeaning'],
      frenchMeaning: json['frenchMeaning'],
      exampleSentence: json['exampleSentence'],
      exampleTranslation: json['exampleTranslation'],
      frenchExampleTranslation: json['frenchExampleTranslation'],
      difficulty: (json['difficulty'] ?? '').toString(),
      lessonId: json['lessonId'],
    );
  }
}

class KnowledgeText {
  final String id;
  final String text;
  final String? translation;

  const KnowledgeText({
    required this.id,
    required this.text,
    this.translation,
  });

  factory KnowledgeText.fromJson(Map<String, dynamic> json) {
    return KnowledgeText(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      translation: json['translation'],
    );
  }
}

class BibleVerseEntry {
  final String id;
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String? englishText;
  final String? frenchText;
  final String version;

  const BibleVerseEntry({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    this.englishText,
    this.frenchText,
    required this.version,
  });

  factory BibleVerseEntry.fromJson(Map<String, dynamic> json) {
    return BibleVerseEntry(
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

class BibleChapterSummary {
  final String book;
  final int chapter;
  final String version;
  final int verseCount;

  const BibleChapterSummary({
    required this.book,
    required this.chapter,
    required this.version,
    required this.verseCount,
  });

  factory BibleChapterSummary.fromJson(Map<String, dynamic> json) {
    return BibleChapterSummary(
      book: json['book'] ?? '',
      chapter: json['chapter'] ?? 0,
      version: json['version'] ?? 'ESV',
      verseCount: json['verseCount'] ?? 0,
    );
  }
}

class DailyWordEntry {
  final String id;
  final String word;
  final String? englishMeaning;
  final String? frenchMeaning;
  final String? usageHint;

  const DailyWordEntry({
    required this.id,
    required this.word,
    this.englishMeaning,
    this.frenchMeaning,
    this.usageHint,
  });

  factory DailyWordEntry.fromJson(Map<String, dynamic> json) {
    return DailyWordEntry(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      englishMeaning: json['englishMeaning'],
      frenchMeaning: json['frenchMeaning'],
      usageHint: json['usageHint'],
    );
  }
}

class DailyVerseEntry {
  final String id;
  final String text;
  final String? englishText;
  final String? frenchText;
  final String reference;

  const DailyVerseEntry({
    required this.id,
    required this.text,
    this.englishText,
    this.frenchText,
    required this.reference,
  });

  factory DailyVerseEntry.fromJson(Map<String, dynamic> json) {
    return DailyVerseEntry(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      englishText: json['englishText'],
      frenchText: json['frenchText'],
      reference: json['reference'] ?? '',
    );
  }
}

class NnangaTestResult {
  final String response;
  final bool usedLocalKnowledge;
  final List<String> matchedKeywords;

  const NnangaTestResult({
    required this.response,
    required this.usedLocalKnowledge,
    required this.matchedKeywords,
  });

  factory NnangaTestResult.fromJson(Map<String, dynamic> json) {
    return NnangaTestResult(
      response: json['response'] ?? '',
      usedLocalKnowledge: json['usedLocalKnowledge'] == true,
      matchedKeywords: ((json['matchedKeywords'] ?? []) as List)
          .map((k) => k.toString())
          .toList(),
    );
  }
}

class NnangaConversation {
  final String prompt;
  final String response;
  final String learnerName;
  final DateTime createdAt;

  const NnangaConversation({
    required this.prompt,
    required this.response,
    required this.learnerName,
    required this.createdAt,
  });

  factory NnangaConversation.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return NnangaConversation(
      prompt: json['prompt'] ?? '',
      response: json['response'] ?? '',
      learnerName: user?['fullName'] ?? 'Unknown',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
