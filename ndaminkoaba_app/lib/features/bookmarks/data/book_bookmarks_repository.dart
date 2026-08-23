import '../../../core/network/api_client.dart';
import '../domain/bookmarked_book.dart';

/// Book-scoped favorites — mirrors BookmarksRepository's shape exactly,
/// against the separate /book-bookmarks endpoints (see BookBookmark on the
/// backend for why this isn't folded into the lesson Bookmark model).
class BookBookmarksRepository {
  Future<String?> findBookmarkId({required String userId, required String bookId}) async {
    final response = await ApiClient.dio.get('/book-bookmarks', queryParameters: {
      'userId': userId,
      'bookId': bookId,
    });
    final data = response.data as Map<String, dynamic>;
    final items = (data['data']?['items'] ?? data['items'] ?? []) as List;
    if (items.isEmpty) return null;
    return (items.first as Map<String, dynamic>)['id'] as String;
  }

  Future<String> create({required String userId, required String bookId}) async {
    final response = await ApiClient.dio.post('/book-bookmarks', data: {
      'userId': userId,
      'bookId': bookId,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    return body['id'] as String;
  }

  Future<void> remove(String bookmarkId) async {
    await ApiClient.dio.delete('/book-bookmarks/$bookmarkId');
  }

  Future<List<BookmarkedBook>> getAll({required String userId, int limit = 100}) async {
    final response = await ApiClient.dio.get('/book-bookmarks', queryParameters: {
      'userId': userId,
      'limit': limit,
    });
    final data = response.data as Map<String, dynamic>;
    final items = (data['data']?['items'] ?? data['items'] ?? []) as List;
    return items.map((e) => BookmarkedBook.fromJson(e as Map<String, dynamic>)).toList();
  }
}
