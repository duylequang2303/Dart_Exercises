import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_remote_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/models/activity_model.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_ai_datasource.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;
  final WorkoutRemoteDataSource? remoteDataSource;
  final WorkoutAiDataSource? aiDataSource;

  WorkoutRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
    this.aiDataSource,
  });

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
    String? userId,
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

    if (userId != null && remoteDataSource != null) {
      try {
        final activity = ActivityModel(
          id: workout.id,
          name: workout.name,
          durationMs: workout.duration.inMilliseconds,
          calories: workout.calories,
          date: DateTime.now(),
          type: workout.type,
          exercises: workout.exercises.map((e) => {
            'id': e.id,
            'name': e.name,
            'sets': e.sets,
            'reps': e.reps,
            'durationMs': e.duration.inMilliseconds,
            'restSeconds': e.restSeconds,
          }).toList(),
        );
        await remoteDataSource!.syncWorkout(userId, activity);
      } catch (e) {
        print('Lỗi đồng bộ workout lên server: $e');
      }
    }
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

  @override
  Future<Map<String, dynamic>> parseWorkoutPlan(String userInput) async {
    if (aiDataSource == null) {
      throw Exception('WorkoutAiDataSource is not initialized');
    }
    return aiDataSource!.parseWorkoutPlan(userInput);
  }
}
