import '../repositories/nutrition_repository.dart';

class DeleteMealUseCase {
  final NutritionRepository repository;
  DeleteMealUseCase(this.repository);

  Future<void> call(String uid, String mealId) {
    return repository.deleteMeal(uid, mealId);
  }
}
