import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../badges/domain/badge_entry.dart';
import '../domain/pronunciation_attempt.dart';

class PronunciationSubmitResult {
  final PronunciationAttempt attempt;
  final List<BadgeEntry> newlyEarnedBadges;

  const PronunciationSubmitResult({required this.attempt, required this.newlyEarnedBadges});
}

class PronunciationRepository {
  Future<String> uploadAudio(Uint8List bytes, String filename) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await ApiClient.dio.post('/uploads/audio', data: formData);
    final data = response.data as Map<String, dynamic>;
    return ((data['data'] ?? data) as Map<String, dynamic>)['url'] as String;
  }

  Future<PronunciationSubmitResult> submit({
    required Uint8List audioBytes,
    required String filename,
    required String targetText,
    String? vocabularyId,
    String? lessonId,
  }) async {
    final audioUrl = await uploadAudio(audioBytes, filename);

    final response = await ApiClient.dio.post('/pronunciation-attempts', data: {
      'targetText': targetText,
      'audioUrl': audioUrl,
      if (vocabularyId != null) 'vocabularyId': vocabularyId,
      if (lessonId != null) 'lessonId': lessonId,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final badges = (body['newlyEarnedBadges'] as List<dynamic>? ?? [])
        .map((e) => BadgeEntry.fromJson({...e as Map<String, dynamic>, 'earned': true, 'progress': 0}))
        .toList();

    return PronunciationSubmitResult(
      attempt: PronunciationAttempt.fromJson(body),
      newlyEarnedBadges: badges,
    );
  }

  Future<List<PronunciationAttempt>> history({String? vocabularyId}) async {
    final response = await ApiClient.dio.get('/pronunciation-attempts/history', queryParameters: {
      if (vocabularyId != null) 'vocabularyId': vocabularyId,
    });
    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] ?? data) as List<dynamic>;
    return list.map((e) => PronunciationAttempt.fromJson(e as Map<String, dynamic>)).toList();
  }
}
