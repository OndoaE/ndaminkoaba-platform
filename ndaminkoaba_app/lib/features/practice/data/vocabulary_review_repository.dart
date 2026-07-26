import '../../../core/network/api_client.dart';
import '../../badges/domain/badge_entry.dart';
import '../domain/review_item.dart';

class VocabularyReviewDue {
  final List<ReviewItem> items;
  final int dueCount;

  const VocabularyReviewDue({required this.items, required this.dueCount});
}

class VocabularyReviewRepository {
  Future<VocabularyReviewDue> getDue({int limit = 20}) async {
    final response = await ApiClient.dio.get(
      '/vocabulary-review/due',
      queryParameters: {'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final items = (body['items'] as List<dynamic>)
        .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return VocabularyReviewDue(items: items, dueCount: (body['dueCount'] as num?)?.toInt() ?? 0);
  }

  /// Returns the newly earned badges (if any) so the caller can show a
  /// celebration moment.
  Future<List<BadgeEntry>> grade(String vocabularyId, int grade) async {
    final response = await ApiClient.dio.post(
      '/vocabulary-review/$vocabularyId/grade',
      data: {'grade': grade},
    );
    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final badges = (body['newlyEarnedBadges'] as List<dynamic>? ?? [])
        .map((e) => BadgeEntry.fromJson({...e as Map<String, dynamic>, 'earned': true, 'progress': 0}))
        .toList();
    return badges;
  }
}
