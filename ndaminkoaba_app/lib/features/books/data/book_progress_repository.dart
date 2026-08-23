import '../../../core/network/api_client.dart';

class BookProgressEntry {
  const BookProgressEntry({
    required this.bookId,
    required this.lastPageNumber,
    required this.completed,
  });

  final String bookId;
  final int lastPageNumber;
  final bool completed;

  factory BookProgressEntry.fromJson(Map<String, dynamic> json) {
    return BookProgressEntry(
      bookId: json['bookId'] ?? '',
      lastPageNumber: (json['lastPageNumber'] as num?)?.toInt() ?? 1,
      completed: json['completed'] == true,
    );
  }
}

class BookProgressRepository {
  /// Best-effort, fire-and-forget from the caller's perspective — a failed
  /// record must never block reading, matching LessonHistoryRepository's
  /// recordView shape.
  Future<void> recordProgress({
    required String userId,
    required String bookId,
    required int lastPageNumber,
  }) async {
    await ApiClient.dio.post('/book-progress', data: {
      'userId': userId,
      'bookId': bookId,
      'lastPageNumber': lastPageNumber,
    });
  }

  Future<BookProgressEntry?> getProgress({required String userId, required String bookId}) async {
    final response = await ApiClient.dio.get('/book-progress', queryParameters: {
      'userId': userId,
      'bookId': bookId,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final items = (body['items'] as List?) ?? [];
    if (items.isEmpty) return null;
    return BookProgressEntry.fromJson(items.first as Map<String, dynamic>);
  }

  /// One call for the whole library grid's progress badges, avoiding a
  /// per-card round trip.
  Future<List<BookProgressEntry>> getAllForUser(String userId) async {
    final response = await ApiClient.dio.get('/book-progress', queryParameters: {
      'userId': userId,
      'limit': 200,
    });
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final items = (body['items'] as List?) ?? [];
    return items.map((e) => BookProgressEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
