class StudyProgressSummary {
  const StudyProgressSummary({
    required this.reviewedToday,
    required this.secondsSpentToday,
    required this.currentStreak,
    required this.dailyGoal,
    required this.lastStudyDate,
  });

  final int reviewedToday;
  final int secondsSpentToday;
  final int currentStreak;
  final int dailyGoal;
  final DateTime? lastStudyDate;

  double get reviewProgress {
    if (dailyGoal <= 0) return 0;
    return (reviewedToday / dailyGoal).clamp(0, 1).toDouble();
  }

  int get minutesSpentToday => (secondsSpentToday / 60).round();

  double get timeIntensityProgress {
    const targetSeconds = 20 * 60;
    return (secondsSpentToday / targetSeconds).clamp(0, 1).toDouble();
  }

  double get intensity =>
      ((reviewProgress * 0.65) + (timeIntensityProgress * 0.35))
          .clamp(0, 1)
          .toDouble();
}
