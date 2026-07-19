import '../../../core/network/api_client.dart';
import '../domain/models/bible_verse.dart';

class BibleRepository {
  /// All saved book/chapter combinations with verse counts
  /// (`GET /bible-verses/chapters`), used to build the books list.
  Future<List<BibleChapterInfo>> getChapters({String? languageId}) async {
    final response = await ApiClient.dio.get('/bible-verses/chapters', queryParameters: {
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] ?? data;
    return (items as List)
        .map((item) => BibleChapterInfo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Verses for one chapter, ordered by verse number
  /// (`GET /bible-verses?book=&chapter=`).
  Future<List<BibleVerse>> getVerses({
    required String book,
    required int chapter,
    String? version,
    String? languageId,
  }) async {
    final response = await ApiClient.dio.get('/bible-verses', queryParameters: {
      'book': book,
      'chapter': chapter,
      if (version != null && version.isNotEmpty) 'version': version,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] ?? data;
    return (items as List)
        .map((item) => BibleVerse.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
