/// A book available for learners to read in-app — either an uploaded
/// PDF/EPUB file (fileUrl/fileType set) or a set of admin-authored
/// illustrated pages (fetched separately via `BookRepository.getPages`,
/// see [BookPage]). Never both required.
class Book {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String? fileUrl;
  final String? fileType;
  final String? category;
  final String? level;
  final int? readingTimeMinutes;
  final int? recommendedAge;
  final bool hasImages;
  final int? pageCount;
  final String? languageName;
  final DateTime? createdAt;

  const Book({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    this.fileUrl,
    this.fileType,
    this.category,
    this.level,
    this.readingTimeMinutes,
    this.recommendedAge,
    this.hasImages = false,
    this.pageCount,
    this.languageName,
    this.createdAt,
  });

  /// Illustrated-pages mode is what this book uses when it has pages and no
  /// uploaded file — the reader branches on this to pick between the new
  /// custom reader and the existing PDF/EPUB viewers.
  bool get isPagesMode => fileUrl == null && (pageCount ?? 0) > 0;

  factory Book.fromJson(Map<String, dynamic> json) {
    final language = json['language'] as Map<String, dynamic>?;
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
      category: json['category'],
      level: json['level'],
      readingTimeMinutes: (json['readingTimeMinutes'] as num?)?.toInt(),
      recommendedAge: (json['recommendedAge'] as num?)?.toInt(),
      hasImages: json['hasImages'] == true,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      languageName: language?['name'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
    );
  }
}

/// The seven fixed `BookCategory` enum values, in the mockup's display
/// order — mirrors `kBookCategories` in the admin feature so both sides
/// agree on the full set without a shared package boundary between them.
const kBookCategories = [
  'CONTES',
  'HISTOIRES',
  'CULTURE',
  'VIE_QUOTIDIENNE',
  'PROVERBES',
  'EDUCATION',
  'AUTRE',
];

String bookCategoryLabel(String category) {
  switch (category) {
    case 'CONTES':
      return 'Contes';
    case 'HISTOIRES':
      return 'Histoires';
    case 'CULTURE':
      return 'Culture';
    case 'VIE_QUOTIDIENNE':
      return 'Vie quotidienne';
    case 'PROVERBES':
      return 'Proverbes';
    case 'EDUCATION':
      return 'Éducation';
    case 'AUTRE':
      return 'Autre';
    default:
      return category;
  }
}
