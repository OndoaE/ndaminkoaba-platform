import '../../../core/network/api_client.dart';
import '../domain/knowledge_models.dart';

class KnowledgeRepository {
  Future<List<KnowledgeWord>> getVocabulary({String? search, String? languageId}) async {
    final response = await ApiClient.dio.get('/vocabulary', queryParameters: {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'search': search,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => KnowledgeWord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createVocabulary({
    required String word,
    required String languageId,
    String? englishMeaning,
    String? frenchMeaning,
    String? exampleSentence,
    String? exampleTranslation,
    String? frenchExampleTranslation,
    required String difficulty,
  }) async {
    await ApiClient.dio.post('/vocabulary', data: {
      'word': word,
      'languageId': languageId,
      if (englishMeaning != null && englishMeaning.isNotEmpty) 'englishMeaning': englishMeaning,
      if (frenchMeaning != null && frenchMeaning.isNotEmpty) 'frenchMeaning': frenchMeaning,
      if (exampleSentence != null && exampleSentence.isNotEmpty) 'exampleSentence': exampleSentence,
      if (exampleTranslation != null && exampleTranslation.isNotEmpty)
        'exampleTranslation': exampleTranslation,
      if (frenchExampleTranslation != null && frenchExampleTranslation.isNotEmpty)
        'frenchExampleTranslation': frenchExampleTranslation,
      'difficulty': difficulty,
    });
  }

  Future<void> updateVocabulary(
    String id, {
    required String word,
    String? englishMeaning,
    String? frenchMeaning,
    String? exampleSentence,
    String? exampleTranslation,
    String? frenchExampleTranslation,
    required String difficulty,
  }) async {
    await ApiClient.dio.patch('/vocabulary/$id', data: {
      'word': word,
      'englishMeaning': englishMeaning ?? '',
      'frenchMeaning': frenchMeaning ?? '',
      'exampleSentence': exampleSentence ?? '',
      'exampleTranslation': exampleTranslation ?? '',
      'frenchExampleTranslation': frenchExampleTranslation ?? '',
      'difficulty': difficulty,
    });
  }

  Future<void> deleteVocabulary(String id) async {
    await ApiClient.dio.delete('/vocabulary/$id');
  }

  // --- Knowledge texts (longer text + translation entries) ---

  Future<List<KnowledgeText>> getKnowledgeTexts({String? search, String? languageId}) async {
    final response = await ApiClient.dio.get('/knowledge-texts', queryParameters: {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'search': search,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => KnowledgeText.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createKnowledgeText({
    required String text,
    required String languageId,
    String? translation,
  }) async {
    await ApiClient.dio.post('/knowledge-texts', data: {
      'text': text,
      'languageId': languageId,
      if (translation != null && translation.isNotEmpty) 'translation': translation,
    });
  }

  Future<void> updateKnowledgeText(String id, {required String text, String? translation}) async {
    await ApiClient.dio.patch('/knowledge-texts/$id', data: {
      'text': text,
      'translation': translation ?? '',
    });
  }

  Future<void> deleteKnowledgeText(String id) async {
    await ApiClient.dio.delete('/knowledge-texts/$id');
  }

  // --- Bible verses (chapter-at-a-time parallel text) ---

  Future<void> bulkUpsertBibleVerses(List<Map<String, dynamic>> verses, {required String languageId}) async {
    await ApiClient.dio.post('/bible-verses/bulk', data: {'languageId': languageId, 'verses': verses});
  }

  Future<List<BibleVerseEntry>> getBibleVerses({
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
        .map((item) => BibleVerseEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<BibleChapterSummary>> getBibleChapters({String? languageId}) async {
    final response = await ApiClient.dio.get('/bible-verses/chapters', queryParameters: {
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] ?? data;
    return (items as List)
        .map((item) => BibleChapterSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteBibleChapter({
    required String book,
    required int chapter,
    String? version,
    String? languageId,
  }) async {
    await ApiClient.dio.delete('/bible-verses/chapter', queryParameters: {
      'book': book,
      'chapter': chapter,
      if (version != null && version.isNotEmpty) 'version': version,
      if (languageId != null) 'languageId': languageId,
    });
  }

  Future<void> deleteBibleVerse(String id) async {
    await ApiClient.dio.delete('/bible-verses/$id');
  }

  // --- Daily word / verse (rotating pool shown on the learner dashboard) ---

  Future<List<DailyWordEntry>> getDailyWords({String? search, String? languageId}) async {
    final response = await ApiClient.dio.get('/daily/words', queryParameters: {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'search': search,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => DailyWordEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createDailyWord({
    required String word,
    required String languageId,
    String? englishMeaning,
    String? frenchMeaning,
    String? usageHint,
  }) async {
    await ApiClient.dio.post('/daily/words', data: {
      'word': word,
      'languageId': languageId,
      if (englishMeaning != null && englishMeaning.isNotEmpty) 'englishMeaning': englishMeaning,
      if (frenchMeaning != null && frenchMeaning.isNotEmpty) 'frenchMeaning': frenchMeaning,
      if (usageHint != null && usageHint.isNotEmpty) 'usageHint': usageHint,
    });
  }

  Future<void> updateDailyWord(
    String id, {
    required String word,
    String? englishMeaning,
    String? frenchMeaning,
    String? usageHint,
  }) async {
    await ApiClient.dio.patch('/daily/words/$id', data: {
      'word': word,
      'englishMeaning': englishMeaning ?? '',
      'frenchMeaning': frenchMeaning ?? '',
      'usageHint': usageHint ?? '',
    });
  }

  Future<void> deleteDailyWord(String id) async {
    await ApiClient.dio.delete('/daily/words/$id');
  }

  Future<List<DailyVerseEntry>> getDailyVerses({String? search, String? languageId}) async {
    final response = await ApiClient.dio.get('/daily/verses', queryParameters: {
      'limit': 100,
      if (search != null && search.isNotEmpty) 'search': search,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => DailyVerseEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createDailyVerse({
    required String text,
    required String languageId,
    String? englishText,
    String? frenchText,
    required String reference,
  }) async {
    await ApiClient.dio.post('/daily/verses', data: {
      'text': text,
      'languageId': languageId,
      if (englishText != null && englishText.isNotEmpty) 'englishText': englishText,
      if (frenchText != null && frenchText.isNotEmpty) 'frenchText': frenchText,
      'reference': reference,
    });
  }

  Future<void> updateDailyVerse(
    String id, {
    required String text,
    String? englishText,
    String? frenchText,
    required String reference,
  }) async {
    await ApiClient.dio.patch('/daily/verses/$id', data: {
      'text': text,
      'englishText': englishText ?? '',
      'frenchText': frenchText ?? '',
      'reference': reference,
    });
  }

  Future<void> deleteDailyVerse(String id) async {
    await ApiClient.dio.delete('/daily/verses/$id');
  }

  Future<NnangaTestResult> testNnanga(String prompt, {String? languageId}) async {
    final response = await ApiClient.dio.post('/nnanga/chat', data: {
      'prompt': prompt,
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    return NnangaTestResult.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<List<NnangaConversation>> getRecentConversations() async {
    final response = await ApiClient.dio.get('/nnanga/conversations', queryParameters: {'limit': 20});
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => NnangaConversation.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
