import '../../../core/network/api_client.dart';
import '../domain/badge_entry.dart';

class BadgesRepository {
  Future<List<BadgeEntry>> getBadges() async {
    final response = await ApiClient.dio.get('/badges');
    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] ?? data) as List<dynamic>;
    return list.map((e) => BadgeEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
