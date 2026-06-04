import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

class StopWorkout {
  final WorkoutRepository repository;

  StopWorkout({required this.repository});

  Future<void> execute(
    Duration elapsed, {
    required String name,
    required double calories,
    required int steps,
    required int iconCodePoint,
    required String type,
    required List<ExerciseEntity> exercises,
    String? userId,
  }) async {
    await repository.stopWorkout(
      elapsed,
      name: name,
      calories: calories,
      steps: steps,
      iconCodePoint: iconCodePoint,
      type: type,
      exercises: exercises,
      userId: userId,
    );
  }
}
