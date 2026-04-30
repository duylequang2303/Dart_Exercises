class CoachPlan {
  final List<DailyTask> dailyTasks;
  final List<WeeklyGoal> weeklyGoals;

  const CoachPlan({
    required this.dailyTasks,
    required this.weeklyGoals,
  });
}

class DailyTask {
  final String id;
  final String title;
  final bool isCompleted;

  const DailyTask({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  DailyTask copyWith({bool? isCompleted}) {
    return DailyTask(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WeeklyGoal {
  final String id;
  final String title;
  final int progressPercent;

  const WeeklyGoal({
    required this.id,
    required this.title,
    required this.progressPercent,
  });
}