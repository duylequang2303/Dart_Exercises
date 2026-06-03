import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;

  WorkoutRepositoryImpl({required this.localDataSource});

  @override
  Future<void> startWorkout() async {
    await localDataSource.startWorkout();
  }

  @override
  Future<void> stopWorkout(
    Duration elapsed, {
    required String name,
    required double calories,
    required int steps,
    required int iconCodePoint,
    required String type,
    required List<ExerciseEntity> exercises,
  }) async {
    final workout = WorkoutEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      duration: elapsed,
      exercises: exercises,
      calories: calories,
      steps: steps,
      iconCodePoint: iconCodePoint,
      type: type,
    );
    await localDataSource.saveWorkout(workout);
  }

  @override
  Future<void> updateProgress(Duration elapsed) async {
    return localDataSource.updateProgress(elapsed);
  }

  @override
  Future<List<WorkoutEntity>> getHistory() async {
    return localDataSource.getAllWorkouts();
  }

  @override
  Future<void> saveWorkoutPlan(WorkoutEntity plan) async {
    return localDataSource.saveWorkoutPlan(plan);
  }

  @override
  Future<List<WorkoutEntity>> getWorkoutPlans() async {
    return localDataSource.getWorkoutPlans();
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await localDataSource.deleteWorkout(id);
  }
}
