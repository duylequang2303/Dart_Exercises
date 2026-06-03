import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

abstract class WorkoutRepository {
  Future<void> startWorkout();
  Future<void> stopWorkout(
    Duration elapsed, {
    required String name,
    required double calories,
    required int steps,
    required int iconCodePoint,
    required String type,
    required List<ExerciseEntity> exercises,
  });
  Future<void> updateProgress(Duration elapsed);
  Future<List<WorkoutEntity>> getHistory();
}
