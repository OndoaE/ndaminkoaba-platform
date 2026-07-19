class Certificate {
  final String id;
  final String certificateCode;
  final String courseTitle;
  final String courseId;
  final String level;
  final DateTime issuedAt;
  final String? pdfUrl;

  const Certificate({
    required this.id,
    required this.certificateCode,
    required this.courseTitle,
    required this.courseId,
    required this.level,
    required this.issuedAt,
    this.pdfUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>?;

    return Certificate(
      id: json['id'] ?? '',
      certificateCode: json['certificateCode'] ?? '',
      courseTitle: course?['title'] ?? '',
      courseId: json['courseId'] ?? course?['id'] ?? '',
      level: (course?['level'] ?? '').toString(),
      issuedAt: DateTime.tryParse(json['issuedAt'] ?? '') ?? DateTime.now(),
      pdfUrl: json['pdfUrl'],
    );
  }
}
