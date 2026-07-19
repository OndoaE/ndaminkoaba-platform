import '../../../core/network/api_client.dart';
import '../domain/models/course.dart';
import '../domain/models/course_detail.dart';

class CourseRepository {
  Future<List<Course>> getCourses({String? level, String? languageId}) async {
    final response = await ApiClient.dio.get(
      '/courses',
      queryParameters: {
        'status': 'PUBLISHED',
        'limit': 100,
        if (level != null) 'level': level,
        if (languageId != null) 'languageId': languageId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'];

    return (items as List)
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CourseDetail> getCourseDetail(String courseId) async {
    final response = await ApiClient.dio.get('/courses/$courseId');

    final data = response.data as Map<String, dynamic>;
    final courseData = data['data'] ?? data;

    return CourseDetail.fromJson(courseData as Map<String, dynamic>);
  }

  /// A level unlocks once every course at the level before it has a
  /// `COMPLETED` enrollment for this learner (vacuously true if that prior
  /// level has no courses at all). Beginner is always unlocked.
  Future<Set<String>> getUnlockedLevels(String userId, {String? languageId}) async {
    const levelOrder = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

    final allCourses = await getCourses(languageId: languageId);
    final totalByLevel = <String, int>{};
    for (final course in allCourses) {
      totalByLevel[course.level] = (totalByLevel[course.level] ?? 0) + 1;
    }

    final response = await ApiClient.dio.get(
      '/enrollments',
      queryParameters: {'userId': userId, 'limit': 200},
    );
    final data = response.data as Map<String, dynamic>;
    final items = (data['data']?['items'] ?? data['items']) as List;

    final completedByLevel = <String, int>{};
    for (final item in items) {
      final enrollment = item as Map<String, dynamic>;
      if (enrollment['status'] != 'COMPLETED') continue;
      final course = enrollment['course'] as Map<String, dynamic>?;
      if (languageId != null && course?['languageId'] != languageId) continue;
      final level = course?['level']?.toString();
      if (level == null) continue;
      completedByLevel[level] = (completedByLevel[level] ?? 0) + 1;
    }

    final unlocked = <String>{levelOrder.first};
    for (var i = 1; i < levelOrder.length; i++) {
      final previousLevel = levelOrder[i - 1];
      final total = totalByLevel[previousLevel] ?? 0;
      final completed = completedByLevel[previousLevel] ?? 0;
      if (completed < total) break;
      unlocked.add(levelOrder[i]);
    }

    return unlocked;
  }
}
