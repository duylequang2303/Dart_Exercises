import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

/// Domain entity representing a Workout composed of Exercises.
class WorkoutEntity {
  final String id;
  final String name;
  final Duration duration;
  final List<ExerciseEntity> exercises;
  final double calories;
  final int steps;
  final int iconCodePoint;

  final String type; // 'strength' or 'cardio'

  const WorkoutEntity({
    required this.id,
    required this.name,
    required this.duration,
    required this.exercises,
    this.calories = 0.0,
    this.steps = 0,
    this.iconCodePoint = 0,
    this.type = 'cardio',
  });

  WorkoutEntity copyWith({
    String? id,
    String? name,
    Duration? duration,
    List<ExerciseEntity>? exercises,
    double? calories,
    int? steps,
    int? iconCodePoint,
    String? type,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      type: type ?? this.type,
    );
  }
}
