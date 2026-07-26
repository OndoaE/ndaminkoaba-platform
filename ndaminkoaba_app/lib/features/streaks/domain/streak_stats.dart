class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final int dailyGoalMinutes;
  final int todayMinutes;

  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyGoalMinutes,
    required this.todayMinutes,
  });

  factory StreakStats.fromJson(Map<String, dynamic> json) {
    return StreakStats(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ?? 10,
      todayMinutes: (json['todayMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
