import '../../../core/network/api_client.dart';
import '../domain/dashboard_stats.dart';
import '../domain/daily_content.dart';

class DashboardRepository {
  Future<DashboardStats> getLearnerDashboard(String userId) async {
    final response = await ApiClient.dio.get('/dashboard/learner/$userId');

    final data = response.data as Map<String, dynamic>;
    final statsData = data['data'] ?? data;

    return DashboardStats.fromJson(statsData as Map<String, dynamic>);
  }

  /// Returns null if the admin-managed daily word pool is empty.
  Future<DailyWord?> getDailyWord({String? languageId}) async {
    final response = await ApiClient.dio.get('/daily/word', queryParameters: {
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final wordData = data['data'] ?? data;
    if (wordData == null) return null;
    return DailyWord.fromJson(wordData as Map<String, dynamic>);
  }

  /// Returns null if the admin-managed daily verse pool is empty.
  Future<DailyVerse?> getDailyVerse({String? languageId}) async {
    final response = await ApiClient.dio.get('/daily/verse', queryParameters: {
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    final verseData = data['data'] ?? data;
    if (verseData == null) return null;
    return DailyVerse.fromJson(verseData as Map<String, dynamic>);
  }
}
