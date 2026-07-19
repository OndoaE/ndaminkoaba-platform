class CourseDetail {
  final String id;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final String level;
  final List<CourseDetailModule> modules;

  CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.level,
    required this.modules,
  });

  int get lessonCount =>
      modules.fold(0, (sum, module) => sum + module.lessons.length);

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      level: (json['level'] ?? '').toString(),
      modules: ((json['modules'] ?? []) as List)
          .map((item) => CourseDetailModule.fromJson(item))
          .toList(),
    );
  }
}

class CourseDetailModule {
  final String id;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final int orderNumber;
  final List<CourseDetailLesson> lessons;

  CourseDetailModule({
    required this.id,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.orderNumber,
    required this.lessons,
  });

  factory CourseDetailModule.fromJson(Map<String, dynamic> json) {
    return CourseDetailModule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      orderNumber: json['orderNumber'] ?? 0,
      lessons: ((json['lessons'] ?? []) as List)
          .map((item) => CourseDetailLesson.fromJson(item))
          .toList(),
    );
  }
}

class CourseDetailLesson {
  final String id;
  final String title;
  final String summary;
  final String? frenchTitle;
  final String? frenchSummary;
  final int orderNumber;

  CourseDetailLesson({
    required this.id,
    required this.title,
    required this.summary,
    this.frenchTitle,
    this.frenchSummary,
    required this.orderNumber,
  });

  factory CourseDetailLesson.fromJson(Map<String, dynamic> json) {
    return CourseDetailLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchSummary: json['frenchSummary'],
      orderNumber: json['orderNumber'] ?? 0,
    );
  }
}