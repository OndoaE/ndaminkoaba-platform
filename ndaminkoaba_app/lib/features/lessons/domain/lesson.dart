class ConversationLine {
  final String speaker;
  final String text;
  final String? frenchText;

  const ConversationLine({required this.speaker, required this.text, this.frenchText});

  factory ConversationLine.fromJson(Map<String, dynamic> json) {
    return ConversationLine(
      speaker: json['speaker'] ?? '',
      text: json['text'] ?? '',
      frenchText: json['frenchText'],
    );
  }
}

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
  final List<ConversationLine> conversation;

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
    this.conversation = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final conversationJson = json['conversationJson'] as List<dynamic>?;

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
      conversation: conversationJson
              ?.map((e) => ConversationLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
