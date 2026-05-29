import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';

class StartWorkout {
  final WorkoutRepository repository;

  StartWorkout({required this.repository});

  Future<void> execute() async {
    await repository.startWorkout();
  }
}
