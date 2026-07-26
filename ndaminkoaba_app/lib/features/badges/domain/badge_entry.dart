class BadgeEntry {
  final String id;
  final String code;
  final String name;
  final String? frenchName;
  final String description;
  final String? frenchDescription;
  final String criteriaType;
  final int criteriaValue;
  final bool earned;
  final DateTime? earnedAt;
  final int progress;

  const BadgeEntry({
    required this.id,
    required this.code,
    required this.name,
    this.frenchName,
    required this.description,
    this.frenchDescription,
    required this.criteriaType,
    required this.criteriaValue,
    required this.earned,
    this.earnedAt,
    required this.progress,
  });

  factory BadgeEntry.fromJson(Map<String, dynamic> json) {
    return BadgeEntry(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      frenchName: json['frenchName'] as String?,
      description: json['description'] as String,
      frenchDescription: json['frenchDescription'] as String?,
      criteriaType: json['criteriaType'] as String,
      criteriaValue: (json['criteriaValue'] as num?)?.toInt() ?? 0,
      earned: json['earned'] as bool? ?? false,
      earnedAt: json['earnedAt'] != null ? DateTime.tryParse(json['earnedAt'] as String) : null,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
    );
  }
}
