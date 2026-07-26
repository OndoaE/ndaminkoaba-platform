import '../../../core/network/api_client.dart';
import '../domain/notification_entry.dart';

class NotificationsRepository {
  Future<List<NotificationEntry>> getMy({bool? isRead}) async {
    final response = await ApiClient.dio.get('/notifications', queryParameters: {
      'limit': 20,
      if (isRead != null) 'isRead': isRead.toString(),
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];
    return (items as List)
        .map((item) => NotificationEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await ApiClient.dio.patch('/notifications/$id/read');
  }
}
