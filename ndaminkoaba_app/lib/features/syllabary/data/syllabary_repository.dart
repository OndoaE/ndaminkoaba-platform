import 'dart:convert';
import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../domain/syllabary_models.dart';

/// Shared by both the admin Syllabus Management screen (full read/write +
/// AI extraction) and the learner alphabet/chart screens (read-only).
class SyllabaryRepository {
  // ---------- Learner-facing ----------

  Future<List<String>> getLetters(String languageId) async {
    final response = await ApiClient.dio.get(
      '/syllabary/letters',
      queryParameters: {'languageId': languageId},
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] ?? data) as List;
    return items.whereType<String>().toList();
  }

  Future<List<SyllabaryEntry>> getChart(String languageId, String letter) async {
    final response = await ApiClient.dio.get(
      '/syllabary/chart',
      queryParameters: {'languageId': languageId, 'letter': letter},
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data'] ?? data) as List;
    return items
        .map((e) => SyllabaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------- Admin: CRUD ----------

  Future<List<SyllabaryEntry>> getEntries({
    String? languageId,
    String? letter,
    String? search,
    int page = 1,
    int limit = 200,
  }) async {
    final response = await ApiClient.dio.get('/syllabary/entries', queryParameters: {
      'page': page,
      'limit': limit,
      if (languageId != null) 'languageId': languageId,
      if (letter != null) 'letter': letter,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final items = (body['items'] as List?) ?? [];
    return items
        .map((e) => SyllabaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createEntry({
    String? consonant,
    required String vowel,
    required String syllable,
    String? exampleWord,
    String? translation,
    String? exampleSentence,
    required int orderNumber,
    required String languageId,
  }) async {
    await ApiClient.dio.post('/syllabary/entries', data: {
      if (consonant != null && consonant.isNotEmpty) 'consonant': consonant,
      'vowel': vowel,
      'syllable': syllable,
      if (exampleWord != null && exampleWord.isNotEmpty) 'exampleWord': exampleWord,
      if (translation != null && translation.isNotEmpty) 'translation': translation,
      if (exampleSentence != null && exampleSentence.isNotEmpty)
        'exampleSentence': exampleSentence,
      'orderNumber': orderNumber,
      'languageId': languageId,
    });
  }

  Future<void> updateEntry(
    String id, {
    String? consonant,
    required String vowel,
    required String syllable,
    String? exampleWord,
    String? translation,
    String? exampleSentence,
    required int orderNumber,
  }) async {
    await ApiClient.dio.patch('/syllabary/entries/$id', data: {
      'consonant': consonant ?? '',
      'vowel': vowel,
      'syllable': syllable,
      'exampleWord': exampleWord ?? '',
      'translation': translation ?? '',
      'exampleSentence': exampleSentence ?? '',
      'orderNumber': orderNumber,
    });
  }

  Future<void> deleteEntry(String id) async {
    await ApiClient.dio.delete('/syllabary/entries/$id');
  }

  // ---------- Admin: AI extraction (never writes anything itself) ----------

  Future<SyllabaryExtractionResult> extractChart({
    required Uint8List imageBytes,
    required String mimeType,
    required String languageId,
  }) async {
    final response = await ApiClient.dio.post('/syllabary/extract', data: {
      'imageBase64': base64Encode(imageBytes),
      'mimeType': mimeType,
      'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    return SyllabaryExtractionResult.fromJson(body);
  }
}
