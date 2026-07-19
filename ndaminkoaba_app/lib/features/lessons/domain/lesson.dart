class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String summary;
  final String content;
  final String? frenchTitle;
  final String? frenchSummary;
  final String? frenchContent;
  final String audioUrl;
  final String videoUrl;
  final int orderNumber;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.content,
    this.frenchTitle,
    this.frenchSummary,
    this.frenchContent,
    required this.audioUrl,
    required this.videoUrl,
    required this.orderNumber,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      moduleId: json['moduleId'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      frenchTitle: json['frenchTitle'],
      frenchSummary: json['frenchSummary'],
      frenchContent: json['frenchContent'],
      audioUrl: json['audioUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
    );
  }
}
