class DashboardStats {
  final int completedLessons;
  final int bookmarks;
  final int certificates;
  final int totalQuizAttempts;
  final double averageQuizScore;

  const DashboardStats({
    required this.completedLessons,
    required this.bookmarks,
    required this.certificates,
    required this.totalQuizAttempts,
    required this.averageQuizScore,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
      bookmarks: (json['bookmarks'] as num?)?.toInt() ?? 0,
      certificates: (json['certificates'] as num?)?.toInt() ?? 0,
      totalQuizAttempts: (json['totalQuizAttempts'] as num?)?.toInt() ?? 0,
      averageQuizScore: (json['averageQuizScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
