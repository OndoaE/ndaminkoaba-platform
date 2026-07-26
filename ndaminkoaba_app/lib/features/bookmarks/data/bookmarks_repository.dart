import '../../../core/network/api_client.dart';

class BookmarksRepository {
  /// Returns the bookmark id if this lesson is bookmarked by [userId], else
  /// null — used both to render the bookmark icon's filled/outline state
  /// and to know which id to delete on un-bookmark.
  Future<String?> findBookmarkId({required String userId, required String lessonId}) async {
    final response = await ApiClient.dio.get('/bookmarks', queryParameters: {
      'userId': userId,
      'lessonId': lessonId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = (data['data']?['items'] ?? data['items'] ?? []) as List;
    if (items.isEmpty) return null;
    return (items.first as Map<String, dynamic>)['id'] as String;
  }

  Future<String> create({required String userId, required String lessonId}) async {
    final response = await ApiClient.dio.post('/bookmarks', data: {
      'userId': userId,
      'lessonId': lessonId,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    return body['id'] as String;
  }

  Future<void> remove(String bookmarkId) async {
    await ApiClient.dio.delete('/bookmarks/$bookmarkId');
  }
}
