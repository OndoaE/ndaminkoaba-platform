import '../../../core/network/api_client.dart';
import '../domain/practice_today.dart';

class PracticeRepository {
  Future<PracticeToday> getToday() async {
    final response = await ApiClient.dio.get('/practice/today');
    final data = response.data as Map<String, dynamic>;
    return PracticeToday.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<List<PracticeDay>> getWeeklyCalendar() async {
    final response = await ApiClient.dio.get('/practice/weekly-calendar');
    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] ?? data) as List<dynamic>;
    return list.map((e) => PracticeDay.fromJson(e as Map<String, dynamic>)).toList();
  }
}
