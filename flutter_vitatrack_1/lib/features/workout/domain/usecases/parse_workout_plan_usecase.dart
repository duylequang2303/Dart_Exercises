import '../repositories/workout_repository.dart';

class ParseWorkoutPlanUseCase {
  final WorkoutRepository repository;
  ParseWorkoutPlanUseCase(this.repository);

  Future<Map<String, dynamic>> call(String userInput) {
    return repository.parseWorkoutPlan(userInput);
  }
}
