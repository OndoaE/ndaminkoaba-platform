/// One page of an admin-authored illustrated book — mirrors the backend's
/// `BookPage` Prisma model. Read-only on the learner side (see
/// `AdminBookPage` for the admin-editable mutable equivalent).
class BookPage {
  const BookPage({
    required this.id,
    required this.orderNumber,
    this.illustrationUrl,
    required this.ewondoText,
    this.englishText,
    this.frenchText,
    this.audioUrl,
  });

  final String id;
  final int orderNumber;
  final String? illustrationUrl;
  final String ewondoText;
  final String? englishText;
  final String? frenchText;
  final String? audioUrl;

  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      id: json['id'] ?? '',
      orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
      illustrationUrl: json['illustrationUrl'],
      ewondoText: json['ewondoText'] ?? '',
      englishText: json['englishText'],
      frenchText: json['frenchText'],
      audioUrl: json['audioUrl'],
    );
  }
}
