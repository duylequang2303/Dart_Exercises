// lib/features/workout/domain/entities/activity_entity.dart
class ActivityEntity {
  final String id;
  final String title;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime date;

  ActivityEntity({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.date,
  });
}