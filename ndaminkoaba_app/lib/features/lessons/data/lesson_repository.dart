import '../../../core/network/api_client.dart';
import '../domain/lesson.dart';
import '../domain/models/lesson_image.dart';

class LessonRepository {
  /// Fetches a single lesson by its id (`GET /lessons/:id`).
  Future<Lesson> getLessonById(String lessonId) async {
    final response = await ApiClient.dio.get('/lessons/$lessonId');

    final data = response.data as Map<String, dynamic>;
    final lessonData = data['data'] ?? data;

    return Lesson.fromJson(lessonData as Map<String, dynamic>);
  }

  /// Fetches all lessons belonging to a module (`GET /lessons?moduleId=`),
  /// used to determine lesson order for "next lesson" navigation.
  Future<List<Lesson>> getLessonsByModule(String moduleId) async {
    final response = await ApiClient.dio.get(
      '/lessons',
      queryParameters: {'moduleId': moduleId},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the illustrative images for a lesson (`GET /lesson-images?lessonId=`).
  Future<List<LessonImage>> getLessonImages(String lessonId) async {
    final response = await ApiClient.dio.get(
      '/lesson-images',
      queryParameters: {'lessonId': lessonId, 'limit': 100},
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['data']?['items'] ?? data['items'] ?? [];

    return (items as List)
        .map((item) => LessonImage.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
