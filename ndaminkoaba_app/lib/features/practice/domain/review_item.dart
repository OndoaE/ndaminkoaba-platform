import '../../vocabulary/domain/vocabulary_word.dart';

class ReviewItem {
  final String vocabularyId;
  final VocabularyWord vocabulary;

  const ReviewItem({required this.vocabularyId, required this.vocabulary});

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      vocabularyId: json['vocabularyId'] as String,
      vocabulary: VocabularyWord.fromJson(json['vocabulary'] as Map<String, dynamic>),
    );
  }
}
