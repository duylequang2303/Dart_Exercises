// lib/features/workout/domain/repositories/workout_repository.dart
import '../entities/exercise_entity.dart';
import '../entities/workout_entity.dart';

abstract class WorkoutRepository {
  Future<List<ExerciseEntity>> searchExercises(String query, String category);
  Future<void> saveWorkoutHistory(String uid, WorkoutEntity workout);
  
  // Bổ sung các hàm để phục vụ cho các UseCase đang bị lỗi
  Future<void> startWorkout();
  Future<void> updateProgress(double progress);
}