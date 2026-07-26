class PracticeToday {
  final int minutesToday;
  final int goalMinutes;
  final double progressRatio;

  const PracticeToday({
    required this.minutesToday,
    required this.goalMinutes,
    required this.progressRatio,
  });

  factory PracticeToday.fromJson(Map<String, dynamic> json) {
    return PracticeToday(
      minutesToday: (json['minutesToday'] as num?)?.toInt() ?? 0,
      goalMinutes: (json['goalMinutes'] as num?)?.toInt() ?? 10,
      progressRatio: (json['progressRatio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PracticeDay {
  final DateTime date;
  final bool completed;
  final int minutes;

  const PracticeDay({required this.date, required this.completed, required this.minutes});

  factory PracticeDay.fromJson(Map<String, dynamic> json) {
    return PracticeDay(
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool? ?? false,
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
    );
  }
}
