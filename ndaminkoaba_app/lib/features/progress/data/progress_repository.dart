import '../../../core/network/api_client.dart';

class ProgressRepository {
  /// Marks a lesson as completed for the given user (`POST /progress`).
  /// Also updates the parent course's enrollment progress percentage
  /// server-side, so this is the single source of truth for completion.
  Future<void> markLessonComplete({
    required String userId,
    required String lessonId,
    int? score,
  }) async {
    await ApiClient.dio.post(
      '/progress',
      data: {
        'userId': userId,
        'lessonId': lessonId,
        'completed': true,
        if (score != null) 'score': score,
      },
    );
  }

  /// Returns the set of lessonIds the user has completed, across all courses.
  Future<Set<String>> getCompletedLessonIds(String userId) async {
    final response = await ApiClient.dio.get(
      '/progress',
      queryParameters: {'userId': userId, 'limit': 500},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .where((item) => item['completed'] == true)
        .map((item) => item['lessonId'] as String)
        .toSet();
  }
}
