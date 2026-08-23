/// One row of the learner's lesson-view Historique — mirrors
/// `LessonHistoryService.findAllForUser`'s nested `lesson.module.course`
/// include in `backend-api/src/lesson-history/lesson-history.service.ts`.
class LessonViewEntry {
  final String id;
  final String lessonId;
  final String lessonTitle;
  final String courseId;
  final String courseTitle;
  final DateTime viewedAt;

  const LessonViewEntry({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.courseId,
    required this.courseTitle,
    required this.viewedAt,
  });

  factory LessonViewEntry.fromJson(Map<String, dynamic> json) {
    final lesson = (json['lesson'] ?? {}) as Map<String, dynamic>;
    final module = (lesson['module'] ?? {}) as Map<String, dynamic>;
    final course = (module['course'] ?? {}) as Map<String, dynamic>;
    return LessonViewEntry(
      id: json['id'] ?? '',
      lessonId: lesson['id'] ?? '',
      lessonTitle: lesson['title'] ?? '',
      courseId: course['id'] ?? '',
      courseTitle: course['title'] ?? '',
      viewedAt: DateTime.tryParse(json['viewedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
