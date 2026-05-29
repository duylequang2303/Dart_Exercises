import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

/// Domain entity representing a Workout composed of Exercises.
class WorkoutEntity {
  final String id;
  final String name;
  final Duration duration;
  final List<ExerciseEntity> exercises;

  const WorkoutEntity({
    required this.id,
    required this.name,
    required this.duration,
    required this.exercises,
  });

  WorkoutEntity copyWith({
    String? id,
    String? name,
    Duration? duration,
    List<ExerciseEntity>? exercises,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
    );
  }
}
