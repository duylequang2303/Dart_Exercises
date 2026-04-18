import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';

abstract class WorkoutRepository {
  Future<void> startWorkout();
  Future<void> stopWorkout(Duration elapsed);
  Future<void> updateProgress(Duration elapsed);
  Future<List<WorkoutEntity>> getHistory();
}
