/// A book (PDF or EPUB) as managed by an admin — mirrors the backend's
/// `Book` Prisma model.
class AdminBook {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String fileUrl;
  final String fileType;
  final DateTime createdAt;

  const AdminBook({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    required this.fileUrl,
    required this.fileType,
    required this.createdAt,
  });

  factory AdminBook.fromJson(Map<String, dynamic> json) {
    return AdminBook(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
