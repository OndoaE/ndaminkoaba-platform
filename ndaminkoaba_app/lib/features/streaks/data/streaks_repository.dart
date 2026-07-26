import '../../../core/network/api_client.dart';
import '../domain/streak_stats.dart';

class StreaksRepository {
  Future<StreakStats> getMe() async {
    final response = await ApiClient.dio.get('/streaks/me');
    final data = response.data as Map<String, dynamic>;
    return StreakStats.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<void> updateGoal(int minutes) async {
    await ApiClient.dio.patch('/streaks/goal', data: {'minutes': minutes});
  }
}
