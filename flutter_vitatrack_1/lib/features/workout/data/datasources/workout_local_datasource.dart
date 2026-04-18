import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';

class WorkoutLocalDataSource {
  final List<WorkoutEntity> _storage = [];

  Future<void> startWorkout() async {
    // Placeholder: record start timestamp if needed
  }

  Future<void> saveWorkout(WorkoutEntity workout) async {
    _storage.add(workout);
  }

  Future<void> updateProgress(Duration elapsed) async {
    // No-op in mock implementation
  }

  List<WorkoutEntity> getAllWorkouts() => List.unmodifiable(_storage);
}
