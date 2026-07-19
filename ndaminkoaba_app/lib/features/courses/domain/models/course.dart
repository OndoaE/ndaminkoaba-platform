class Course {
  final String id;
  final String title;
  final String description;
  final String? frenchTitle;
  final String? frenchDescription;
  final String level;
  final String image;
  final int lessons;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.frenchTitle,
    this.frenchDescription,
    required this.level,
    required this.image,
    required this.lessons,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final modules = json['modules'] as List? ?? [];

    int lessonCount = 0;

    for (final module in modules) {
      final lessons = module['lessons'] as List?;
      lessonCount += lessons?.length ?? 0;
    }

    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchDescription: json['frenchDescription'],
      level: (json['level'] ?? '').toString(),
      image: json['thumbnailUrl'] ?? '',
      lessons: lessonCount,
    );
  }
}
