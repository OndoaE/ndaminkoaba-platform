/// A Cameroonian indigenous language (Ewondo, Bassa, Bulu, ...) available to
/// learn on NdaMinkoaba, admin-managed via the Global Dashboard.
class Language {
  final String id;
  final String name;
  final String code;
  final String? country;
  final String? flagUrl;

  const Language({
    required this.id,
    required this.name,
    required this.code,
    this.country,
    this.flagUrl,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      country: json['country'],
      flagUrl: json['flagUrl'],
    );
  }
}
