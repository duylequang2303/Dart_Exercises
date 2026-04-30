import '../../domain/entities/coach_plan.dart';

class CoachPlanModel extends CoachPlan {
  const CoachPlanModel({
    required super.dailyTasks,
    required super.weeklyGoals,
  });

  factory CoachPlanModel.fromJson(Map<String, dynamic> json) {
    final tasksJson = json['dailyTasks'] as List<dynamic>? ?? [];
    final dailyTasks = tasksJson
        .map((e) => DailyTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final goalsJson = json['weeklyGoals'] as List<dynamic>? ?? [];
    final weeklyGoals = goalsJson
        .map((e) => WeeklyGoalModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return CoachPlanModel(
      dailyTasks: dailyTasks,
      weeklyGoals: weeklyGoals,
    );
  }
}

class DailyTaskModel extends DailyTask {
  const DailyTaskModel({
    required super.id,
    required super.title,
    required super.isCompleted,
  });

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyTaskModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

class WeeklyGoalModel extends WeeklyGoal {
  const WeeklyGoalModel({
    required super.id,
    required super.title,
    required super.progressPercent,
  });

  factory WeeklyGoalModel.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
    );
  }
}