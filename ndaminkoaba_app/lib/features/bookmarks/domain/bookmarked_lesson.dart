/// A bookmark row enriched with enough lesson/course context to render and
/// navigate to it from the Favoris screen, mirroring the shape
/// `bookmarks.service.ts`'s `findAll` now returns (`lesson.module.course`).
class BookmarkedLesson {
  final String bookmarkId;
  final String lessonId;
  final String lessonTitle;
  final String? lessonFrenchTitle;
  final String courseId;
  final String courseTitle;
  final DateTime createdAt;

  const BookmarkedLesson({
    required this.bookmarkId,
    required this.lessonId,
    required this.lessonTitle,
    this.lessonFrenchTitle,
    required this.courseId,
    required this.courseTitle,
    required this.createdAt,
  });

  factory BookmarkedLesson.fromJson(Map<String, dynamic> json) {
    final lesson = (json['lesson'] ?? {}) as Map<String, dynamic>;
    final module = (lesson['module'] ?? {}) as Map<String, dynamic>;
    final course = (module['course'] ?? {}) as Map<String, dynamic>;
    return BookmarkedLesson(
      bookmarkId: json['id'] ?? '',
      lessonId: lesson['id'] ?? '',
      lessonTitle: lesson['title'] ?? '',
      lessonFrenchTitle: lesson['frenchTitle'],
      courseId: course['id'] ?? '',
      courseTitle: course['title'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
