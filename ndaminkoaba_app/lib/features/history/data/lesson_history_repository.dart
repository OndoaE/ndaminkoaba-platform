import '../../../core/network/api_client.dart';
import '../domain/lesson_view_entry.dart';

class LessonHistoryRepository {
  /// Fire-and-forget from the caller's perspective — a failed record must
  /// never block lesson rendering, so this throws normally and callers wrap
  /// it in their own best-effort handling rather than swallowing errors here.
  Future<void> recordView({required String userId, required String lessonId}) async {
    await ApiClient.dio.post('/lesson-history', data: {
      'userId': userId,
      'lessonId': lessonId,
    });
  }

  Future<List<LessonViewEntry>> getAll({required String userId, int limit = 50}) async {
    final response = await ApiClient.dio.get('/lesson-history', queryParameters: {
      'userId': userId,
      'limit': limit,
    });
    final data = response.data as Map<String, dynamic>;
    final items = (data['data']?['items'] ?? data['items'] ?? []) as List;
    return items.map((e) => LessonViewEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
