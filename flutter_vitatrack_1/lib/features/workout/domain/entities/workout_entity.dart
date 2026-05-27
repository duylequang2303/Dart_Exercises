// lib/features/workout/domain/entities/workout_entity.dart
class WorkoutEntity {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final int actualDurationInSeconds;
  final int totalCaloriesBurned;
  final DateTime timestamp;

  const WorkoutEntity({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.actualDurationInSeconds,
    required this.totalCaloriesBurned,
    required this.timestamp,
  });
}