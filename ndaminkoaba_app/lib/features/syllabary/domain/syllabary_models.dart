/// One consonant+vowel syllable row in a language's syllabary/literacy
/// chart (e.g. consonant "L" + vowel "a" -> syllable "la"). A standalone
/// vowel "letter" is represented with a null [consonant].
class SyllabaryEntry {
  const SyllabaryEntry({
    required this.id,
    this.consonant,
    required this.vowel,
    required this.syllable,
    this.exampleWord,
    this.translation,
    this.exampleSentence,
    required this.orderNumber,
    required this.languageId,
  });

  final String id;
  final String? consonant;
  final String vowel;
  final String syllable;
  final String? exampleWord;
  final String? translation;
  final String? exampleSentence;
  final int orderNumber;
  final String languageId;

  /// The alphabet-grid "letter" this entry is browsed under.
  String get letter => consonant ?? vowel;

  factory SyllabaryEntry.fromJson(Map<String, dynamic> json) {
    return SyllabaryEntry(
      id: json['id'] ?? '',
      consonant: json['consonant'] as String?,
      vowel: json['vowel'] ?? '',
      syllable: json['syllable'] ?? '',
      exampleWord: json['exampleWord'] as String?,
      translation: json['translation'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
      languageId: json['languageId'] ?? '',
    );
  }
}

/// One row of an AI-extracted chart, before it's been reviewed/approved —
/// fields are mutable so the admin review screen can edit them in place.
class SyllabaryExtractionRow {
  SyllabaryExtractionRow({
    required this.vowel,
    required this.syllable,
    this.exampleWord,
    this.translation,
    this.exampleSentence,
    required this.orderNumber,
    this.confidence = 'high',
  });

  String vowel;
  String syllable;
  String? exampleWord;
  String? translation;
  String? exampleSentence;
  int orderNumber;
  String confidence;

  factory SyllabaryExtractionRow.fromJson(Map<String, dynamic> json) {
    return SyllabaryExtractionRow(
      vowel: json['vowel'] ?? '',
      syllable: json['syllable'] ?? '',
      exampleWord: json['exampleWord'] as String?,
      translation: json['translation'] as String?,
      exampleSentence: json['exampleSentence'] as String?,
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
      confidence: json['confidence'] == 'low' ? 'low' : 'high',
    );
  }
}

class SyllabaryExtractionResult {
  SyllabaryExtractionResult({
    required this.consonant,
    required this.rows,
    required this.warnings,
  });

  String? consonant;
  List<SyllabaryExtractionRow> rows;
  List<String> warnings;

  factory SyllabaryExtractionResult.fromJson(Map<String, dynamic> json) {
    return SyllabaryExtractionResult(
      consonant: json['consonant'] as String?,
      rows: ((json['rows'] as List?) ?? [])
          .map((r) => SyllabaryExtractionRow.fromJson(r as Map<String, dynamic>))
          .toList(),
      warnings: ((json['warnings'] as List?) ?? []).whereType<String>().toList(),
    );
  }
}
