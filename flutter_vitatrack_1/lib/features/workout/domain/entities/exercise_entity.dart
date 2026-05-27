// lib/features/workout/domain/entities/exercise_entity.dart
class ExerciseEntity {
  final String id;
  final String name;
  final int durationInMinutes;
  final int caloriesBurned;
  final String category;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.durationInMinutes,
    required this.caloriesBurned,
    required this.category,
  });
}