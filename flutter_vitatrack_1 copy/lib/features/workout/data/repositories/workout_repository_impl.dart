import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource localDataSource;

  WorkoutRepositoryImpl({required this.localDataSource});

  @override
  Future<void> startWorkout() async {
    await localDataSource.startWorkout();
  }

  @override
  Future<void> stopWorkout(Duration elapsed) async {
    final workout = WorkoutEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Workout',
      duration: elapsed,
      exercises: const [],
    );
    await localDataSource.saveWorkout(workout);
  }

  @override
  Future<void> updateProgress(Duration elapsed) async {
    await localDataSource.updateProgress(elapsed);
  }

  @override
  Future<List<WorkoutEntity>> getHistory() async {
    return localDataSource.getAllWorkouts();
  }
}
