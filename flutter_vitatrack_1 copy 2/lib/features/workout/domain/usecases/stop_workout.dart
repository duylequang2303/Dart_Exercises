import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';

class StopWorkout {
  final WorkoutRepository repository;

  StopWorkout({required this.repository});

  Future<void> execute(Duration elapsed) async {
    await repository.stopWorkout(elapsed);
  }
}
