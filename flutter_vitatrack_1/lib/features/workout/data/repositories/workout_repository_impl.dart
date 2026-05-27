// lib/features/workout/data/repositories/workout_repository_impl.dart
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_entity.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_remote_datasource.dart';
import '../models/activity_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDatasource _remoteDatasource;

  WorkoutRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<ExerciseEntity>> searchExercises(String query, String category) async {
    // SỬA TẠI ĐÂY: Gọi đúng tên hàm searchExercises với tham số đặt tên muscleId (truyền category vào)
    return await _remoteDatasource.searchExercises(
      query: query,
      muscleId: category, 
    );
  }

  @override
  Future<void> saveWorkoutHistory(String uid, WorkoutEntity workout) async {
    final model = WorkoutModel(
      id: workout.id,
      exerciseId: workout.exerciseId,
      exerciseName: workout.exerciseName,
      actualDurationInSeconds: workout.actualDurationInSeconds,
      totalCaloriesBurned: workout.totalCaloriesBurned,
      timestamp: workout.timestamp,
    );
    await _remoteDatasource.saveWorkoutToFirestore(uid, model);
  }

  @override
  Future<void> startWorkout() async {}

  @override
  Future<void> updateProgress(double progress) async {}
}