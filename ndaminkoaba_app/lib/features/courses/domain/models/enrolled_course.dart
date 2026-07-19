class EnrolledCourse {
  final String courseId;
  final String title;
  final String? frenchTitle;
  final String level;
  final int lessons;
  final int progress;
  final String status;

  const EnrolledCourse({
    required this.courseId,
    required this.title,
    this.frenchTitle,
    required this.level,
    required this.lessons,
    required this.progress,
    required this.status,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? {};
    final modules = course['modules'] as List? ?? [];

    int lessonCount = 0;
    for (final module in modules) {
      final lessons = (module as Map<String, dynamic>)['lessons'] as List?;
      lessonCount += lessons?.length ?? 0;
    }

    return EnrolledCourse(
      courseId: course['id'] ?? json['courseId'] ?? '',
      title: course['title'] ?? '',
      frenchTitle: course['frenchTitle'],
      level: (course['level'] ?? '').toString(),
      lessons: lessonCount,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
    );
  }
}
