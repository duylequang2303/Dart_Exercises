import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_remote_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/activity_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;
  final WorkoutRemoteDataSource remoteDataSource;

  WorkoutRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> startWorkout() async {
    await localDataSource.startWorkout();
  }

  @override
  Future<void> stopWorkout(String uid, Duration elapsed) async {
    final workout = WorkoutEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Workout',
      duration: elapsed,
      exercises: const [],
    );
    await localDataSource.saveWorkout(workout);
    await remoteDataSource.saveWorkout(uid, workout);
  }

  @override
  Future<void> updateProgress(Duration elapsed) async {
    await localDataSource.updateProgress(elapsed);
  }

  @override
  Future<List<WorkoutEntity>> getHistory() async {
    return localDataSource.getAllWorkouts();
  }

  @override
  Future<List<ActivityEntity>> searchExercises({String query = '', int? muscleId}) async {
    return await remoteDataSource.searchExercises(query: query, muscleId: muscleId);
  }
}
