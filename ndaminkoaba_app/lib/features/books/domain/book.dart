/// A book (PDF or EPUB) available for learners to read in-app.
class Book {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String fileUrl;
  final String fileType;

  const Book({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    required this.fileUrl,
    required this.fileType,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
    );
  }
}
