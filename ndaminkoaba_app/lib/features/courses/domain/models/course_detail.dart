import '../../../lessons/domain/lesson.dart';
import '../../../offline/domain/course_download_manifest.dart';

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

  /// Builds the same shape a live `GET /courses/:id` would, from a
  /// downloaded course's on-disk manifest — lets every screen that renders
  /// a `CourseDetail` keep working unmodified when falling back offline.
  factory CourseDetail.fromManifest(CourseDownloadManifest manifest) {
    return CourseDetail(
      id: manifest.courseId,
      title: manifest.title,
      description: manifest.description,
      frenchTitle: manifest.frenchTitle,
      frenchDescription: manifest.frenchDescription,
      level: manifest.level,
      modules: manifest.modules
          .map((module) => CourseDetailModule.fromOfflineModule(module))
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

  factory CourseDetailModule.fromOfflineModule(OfflineModule module) {
    return CourseDetailModule(
      id: module.id,
      title: module.title,
      description: module.description,
      frenchTitle: module.frenchTitle,
      frenchDescription: module.frenchDescription,
      orderNumber: module.orderNumber,
      lessons: module.lessons
          .map((lesson) => CourseDetailLesson.fromLesson(lesson.lesson))
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

  factory CourseDetailLesson.fromLesson(Lesson lesson) {
    return CourseDetailLesson(
      id: lesson.id,
      title: lesson.title,
      summary: lesson.summary,
      frenchTitle: lesson.frenchTitle,
      frenchSummary: lesson.frenchSummary,
      orderNumber: lesson.orderNumber,
    );
  }
}
