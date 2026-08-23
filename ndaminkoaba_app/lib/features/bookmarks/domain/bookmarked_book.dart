/// A book-bookmark row enriched with enough book context to render and
/// navigate to it from the Favoris screen — mirrors `BookmarkedLesson`'s
/// shape for the lesson side.
class BookmarkedBook {
  const BookmarkedBook({
    required this.bookmarkId,
    required this.bookId,
    required this.bookTitle,
    this.coverUrl,
    required this.createdAt,
  });

  final String bookmarkId;
  final String bookId;
  final String bookTitle;
  final String? coverUrl;
  final DateTime createdAt;

  factory BookmarkedBook.fromJson(Map<String, dynamic> json) {
    final book = (json['book'] ?? {}) as Map<String, dynamic>;
    return BookmarkedBook(
      bookmarkId: json['id'] ?? '',
      bookId: book['id'] ?? '',
      bookTitle: book['title'] ?? '',
      coverUrl: book['coverUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
