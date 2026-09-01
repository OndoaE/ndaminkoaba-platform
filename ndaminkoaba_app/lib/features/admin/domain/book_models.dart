/// A book (PDF/EPUB upload, or admin-authored illustrated pages) as
/// managed by an admin — mirrors the backend's `Book` Prisma model. A book
/// is either file-mode (fileUrl/fileType set) or pages-mode (BookPage rows
/// exist, fetched separately via `BookRepository.getPages`) — both
/// optional, chosen per book, never both required.
class AdminBook {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? frenchDescription;
  final String? coverUrl;
  final String? fileUrl;
  final String? fileType;
  final String? category;
  final String? level;
  final int? readingTimeMinutes;
  final int? recommendedAge;
  final bool hasImages;
  final int? pageCount;
  final String languageId;
  final DateTime createdAt;

  const AdminBook({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.frenchDescription,
    this.coverUrl,
    this.fileUrl,
    this.fileType,
    this.category,
    this.level,
    this.readingTimeMinutes,
    this.recommendedAge,
    this.hasImages = false,
    this.pageCount,
    this.languageId = '',
    required this.createdAt,
  });

  factory AdminBook.fromJson(Map<String, dynamic> json) {
    return AdminBook(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'],
      description: json['description'],
      frenchDescription: json['frenchDescription'],
      coverUrl: json['coverUrl'],
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
      category: json['category'],
      level: json['level'],
      readingTimeMinutes: (json['readingTimeMinutes'] as num?)?.toInt(),
      recommendedAge: (json['recommendedAge'] as num?)?.toInt(),
      hasImages: json['hasImages'] == true,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      languageId: json['languageId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// One page of an admin-authored illustrated book — mirrors the backend's
/// `BookPage` Prisma model. Fields are mutable so the page-editor card can
/// edit them in place, matching `SyllabaryExtractionRow`'s pattern.
class AdminBookPage {
  AdminBookPage({
    required this.id,
    required this.bookId,
    required this.orderNumber,
    this.illustrationUrl,
    required this.ewondoText,
    this.englishText,
    this.frenchText,
    this.audioUrl,
  });

  final String id;
  final String bookId;
  int orderNumber;
  String? illustrationUrl;
  String ewondoText;
  String? englishText;
  String? frenchText;
  String? audioUrl;

  factory AdminBookPage.fromJson(Map<String, dynamic> json) {
    return AdminBookPage(
      id: json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
      illustrationUrl: json['illustrationUrl'],
      ewondoText: json['ewondoText'] ?? '',
      englishText: json['englishText'],
      frenchText: json['frenchText'],
      audioUrl: json['audioUrl'],
    );
  }
}

/// The seven fixed `BookCategory` enum values, in the mockup's display
/// order — shared by the admin category picker and the learner-side
/// filter pills so both always agree on the full set.
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
