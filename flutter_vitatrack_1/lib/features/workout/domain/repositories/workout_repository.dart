import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/activity_entity.dart';

abstract class WorkoutRepository {
  Future<void> startWorkout();
  Future<void> stopWorkout(String uid, Duration elapsed);
  Future<void> updateProgress(Duration elapsed);
  Future<List<WorkoutEntity>> getHistory();
  Future<List<ActivityEntity>> searchExercises({String query = '', int? muscleId});
}
