class PronunciationAttempt {
  final String id;
  final String targetText;
  final String? transcript;
  final int? accuracyScore;
  final String? feedback;
  final String status;

  const PronunciationAttempt({
    required this.id,
    required this.targetText,
    this.transcript,
    this.accuracyScore,
    this.feedback,
    required this.status,
  });

  bool get scored => status == 'SCORED';

  factory PronunciationAttempt.fromJson(Map<String, dynamic> json) {
    return PronunciationAttempt(
      id: json['id'] as String,
      targetText: json['targetText'] as String,
      transcript: json['transcript'] as String?,
      accuracyScore: (json['accuracyScore'] as num?)?.toInt(),
      feedback: json['feedback'] as String?,
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}
