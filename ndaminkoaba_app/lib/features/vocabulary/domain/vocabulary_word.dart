class VocabularyWord {
  final String id;
  final String word;
  final String? frenchMeaning;
  final String? englishMeaning;
  final String? exampleSentence;
  final String difficulty;
  final String? categoryName;

  const VocabularyWord({
    required this.id,
    required this.word,
    this.frenchMeaning,
    this.englishMeaning,
    this.exampleSentence,
    required this.difficulty,
    this.categoryName,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return VocabularyWord(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      frenchMeaning: json['frenchMeaning'],
      englishMeaning: json['englishMeaning'],
      exampleSentence: json['exampleSentence'],
      difficulty: (json['difficulty'] ?? '').toString(),
      categoryName: category?['name'],
    );
  }
}
