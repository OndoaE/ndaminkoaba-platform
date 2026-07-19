class LessonImage {
  final String id;
  final String lessonId;
  final String imageUrl;
  final String word;
  final String? caption;
  final int orderNumber;

  const LessonImage({
    required this.id,
    required this.lessonId,
    required this.imageUrl,
    required this.word,
    this.caption,
    required this.orderNumber,
  });

  factory LessonImage.fromJson(Map<String, dynamic> json) {
    return LessonImage(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      word: json['word'] ?? '',
      caption: json['caption'],
      orderNumber: json['orderNumber'] ?? 1,
    );
  }
}
