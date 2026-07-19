import '../../../core/network/api_client.dart';
import '../domain/vocabulary_word.dart';

class VocabularyRepository {
  Future<List<VocabularyWord>> getVocabulary({
    String? difficulty,
    String? search,
    String? languageId,
  }) async {
    final response = await ApiClient.dio.get(
      '/vocabulary',
      queryParameters: {
        'limit': 100,
        if (difficulty != null) 'difficulty': difficulty,
        if (search != null && search.isNotEmpty) 'search': search,
        if (languageId != null) 'languageId': languageId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .map((item) => VocabularyWord.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
