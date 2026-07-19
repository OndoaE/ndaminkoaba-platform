import '../../../core/network/api_client.dart';
import '../domain/admin_models.dart';

class AdminRepository {
  Future<AdminStats> getStats({String? languageId}) async {
    final response = await ApiClient.dio.get('/dashboard/admin', queryParameters: {
      if (languageId != null) 'languageId': languageId,
    });
    final data = response.data as Map<String, dynamic>;
    return AdminStats.fromJson((data['data'] ?? data) as Map<String, dynamic>);
  }

  Future<List<AdminUser>> getUsers({String? role, String? search}) async {
    final response = await ApiClient.dio.get(
      '/users',
      queryParameters: {
        'limit': 100,
        if (role != null) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .map((item) => AdminUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    await ApiClient.dio.post('/users', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<void> setUserActive(String userId, bool isActive) async {
    await ApiClient.dio.patch('/users/$userId', data: {'isActive': isActive});
  }

  Future<void> broadcastAnnouncement(String title, String message) async {
    await ApiClient.dio.post('/notifications/broadcast', data: {
      'title': title,
      'message': message,
    });
  }

  Future<void> setUserRole(String userId, String role) async {
    await ApiClient.dio.patch('/users/$userId', data: {'role': role});
  }

  Future<List<AdminCourse>> getCourses({String? status, String? level, String? languageId}) async {
    final response = await ApiClient.dio.get(
      '/courses',
      queryParameters: {
        'limit': 100,
        if (status != null) 'status': status,
        if (level != null) 'level': level,
        if (languageId != null) 'languageId': languageId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .map((item) => AdminCourse.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> setCourseStatus(String courseId, String status) async {
    await ApiClient.dio.patch('/courses/$courseId', data: {'status': status});
  }

  Future<List<AdminCertificate>> getCertificates() async {
    final response = await ApiClient.dio.get(
      '/certificates',
      queryParameters: {'limit': 100},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .map((item) => AdminCertificate.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Paginated audit trail of admin/teacher actions across every shared
  /// content pool. [entity] filters to one kind (e.g. "Course"); omit for all.
  Future<({List<AuditLogEntry> items, int page, int totalPages})> getAuditLogs({
    int page = 1,
    String? entity,
  }) async {
    final response = await ApiClient.dio.get('/audit-logs', queryParameters: {
      'page': page,
      'limit': 20,
      if (entity != null && entity.isNotEmpty) 'entity': entity,
    });

    final data = response.data as Map<String, dynamic>;
    final body = (data['data'] ?? data) as Map<String, dynamic>;
    final items = (body['items'] ?? []) as List;

    return (
      items: items.map((item) => AuditLogEntry.fromJson(item as Map<String, dynamic>)).toList(),
      page: (body['page'] ?? 1) as int,
      totalPages: (body['totalPages'] ?? 1) as int,
    );
  }
}
