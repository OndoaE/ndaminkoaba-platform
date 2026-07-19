class ManagedModule {
  final String id;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final int orderNumber;
  final String courseId;
  final String courseTitle;
  final String courseLevel;
  final int lessonCount;

  const ManagedModule({
    required this.id,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.orderNumber,
    required this.courseId,
    required this.courseTitle,
    required this.courseLevel,
    required this.lessonCount,
  });

  factory ManagedModule.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>?;
    return ManagedModule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      orderNumber: json['orderNumber'] ?? 1,
      courseId: json['courseId'] ?? '',
      courseTitle: course?['title'] ?? 'Unknown course',
      courseLevel: (course?['level'] ?? '').toString(),
      lessonCount: ((json['lessons'] ?? []) as List).length,
    );
  }
}

class ManagedLesson {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String? frenchTitle;
  final String? frenchSummary;
  final String? frenchContent;
  final int orderNumber;
  final String moduleId;
  final String moduleTitle;
  final String courseId;
  final String courseTitle;
  final bool hasQuiz;

  const ManagedLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.frenchTitle,
    this.frenchSummary,
    this.frenchContent,
    required this.orderNumber,
    required this.moduleId,
    required this.moduleTitle,
    required this.courseId,
    required this.courseTitle,
    required this.hasQuiz,
  });

  factory ManagedLesson.fromJson(Map<String, dynamic> json) {
    final module = json['module'] as Map<String, dynamic>?;
    final course = module?['course'] as Map<String, dynamic>?;
    return ManagedLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchSummary: json['frenchSummary'],
      frenchContent: json['frenchContent'],
      orderNumber: json['orderNumber'] ?? 1,
      moduleId: json['moduleId'] ?? '',
      moduleTitle: module?['title'] ?? 'Unknown module',
      courseId: course?['id'] ?? '',
      courseTitle: course?['title'] ?? 'Unknown course',
      hasQuiz: ((json['quizzes'] ?? []) as List).isNotEmpty,
    );
  }
}

class ManagedQuiz {
  final String id;
  final String title;
  final String? description;
  final String? frenchTitle;
  final String? frenchDescription;
  final int passingScore;
  final int questionCount;
  final String lessonId;
  final String lessonTitle;
  final String moduleTitle;
  final String courseTitle;

  const ManagedQuiz({
    required this.id,
    required this.title,
    this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.passingScore,
    required this.questionCount,
    required this.lessonId,
    required this.lessonTitle,
    required this.moduleTitle,
    required this.courseTitle,
  });

  factory ManagedQuiz.fromJson(Map<String, dynamic> json) {
    final lesson = json['lesson'] as Map<String, dynamic>?;
    final module = lesson?['module'] as Map<String, dynamic>?;
    final course = module?['course'] as Map<String, dynamic>?;
    return ManagedQuiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      passingScore: json['passingScore'] ?? 80,
      questionCount: ((json['questions'] ?? []) as List).length,
      lessonId: json['lessonId'] ?? '',
      lessonTitle: lesson?['title'] ?? 'Unknown lesson',
      moduleTitle: module?['title'] ?? 'Unknown module',
      courseTitle: course?['title'] ?? 'Unknown course',
    );
  }
}
