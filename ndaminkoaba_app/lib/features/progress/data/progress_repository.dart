import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/services/sync_queue_service.dart';

class ProgressRepository {
  /// Marks a lesson as completed for the given user (`POST /progress`).
  /// Also updates the parent course's enrollment progress percentage
  /// server-side, so this is the single source of truth for completion.
  ///
  /// `POST /progress` upserts on `(userId, lessonId)` server-side, so it's
  /// safe to queue-and-replay: a connectivity failure here is queued via
  /// [SyncQueueService] instead of propagating, so callers no longer need
  /// to treat a failed completion call as a dead end.
  Future<void> markLessonComplete({
    required String userId,
    required String lessonId,
    int? score,
  }) async {
    try {
      await ApiClient.dio.post(
        '/progress',
        data: {
          'userId': userId,
          'lessonId': lessonId,
          'completed': true,
          if (score != null) 'score': score,
        },
      );
    } on DioException catch (e) {
      if (!isConnectivityFailure(e)) rethrow;
      await SyncQueueService().enqueue(SyncOpType.markLessonComplete, {
        'userId': userId,
        'lessonId': lessonId,
        if (score != null) 'score': score,
      });
    }
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
