import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../domain/models/enrolled_course.dart';

class EnrollmentRepository {
  /// Enrolls the user in a course. Safe to call every time a course is
  /// opened — a 409 (already enrolled) is treated as a no-op.
  Future<void> ensureEnrolled({
    required String userId,
    required String courseId,
  }) async {
    try {
      await ApiClient.dio.post(
        '/enrollments',
        data: {'userId': userId, 'courseId': courseId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode != 409) rethrow;
    }
  }

  Future<List<EnrolledCourse>> getMyEnrollments(String userId) async {
    final response = await ApiClient.dio.get(
      '/enrollments',
      queryParameters: {'userId': userId, 'limit': 100},
    );

    final data = response.data as Map<String, dynamic>;
    final items = (data['data']?['items'] ?? data['items']) as List;

    return items
        .map((item) => EnrolledCourse.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
