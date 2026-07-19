import 'package:shared_preferences/shared_preferences.dart';

class LessonProgressService {
  static String _key(String courseId, String lessonId) {
    return 'lesson_completed_${courseId}_$lessonId';
  }

  Future<void> markCompleted({
    required String courseId,
    required String lessonId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _key(courseId, lessonId),
      true,
    );
  }

  Future<bool> isCompleted({
    required String courseId,
    required String lessonId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
          _key(courseId, lessonId),
        ) ??
        false;
  }
}