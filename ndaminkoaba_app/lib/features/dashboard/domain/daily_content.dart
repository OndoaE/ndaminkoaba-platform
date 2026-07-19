class DailyWord {
  final String word;
  final String? englishMeaning;
  final String? frenchMeaning;
  final String? usageHint;

  const DailyWord({
    required this.word,
    this.englishMeaning,
    this.frenchMeaning,
    this.usageHint,
  });

  factory DailyWord.fromJson(Map<String, dynamic> json) {
    return DailyWord(
      word: json['word'] ?? '',
      englishMeaning: json['englishMeaning'],
      frenchMeaning: json['frenchMeaning'],
      usageHint: json['usageHint'],
    );
  }
}

class DailyVerse {
  final String text;
  final String? englishText;
  final String? frenchText;
  final String reference;

  const DailyVerse({
    required this.text,
    this.englishText,
    this.frenchText,
    required this.reference,
  });

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      text: json['text'] ?? '',
      englishText: json['englishText'],
      frenchText: json['frenchText'],
      reference: json['reference'] ?? '',
    );
  }
}
