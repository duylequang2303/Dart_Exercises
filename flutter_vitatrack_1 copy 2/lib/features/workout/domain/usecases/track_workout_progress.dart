import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';

class TrackWorkoutProgress {
  final WorkoutRepository repository;

  TrackWorkoutProgress({required this.repository});

  Future<void> execute(Duration elapsed) async {
    await repository.updateProgress(elapsed);
  }
}
