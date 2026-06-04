import '../entities/nutrition.dart';
import '../repositories/nutrition_repository.dart';

class GetNutritionTodayUseCase {
  final NutritionRepository repository;
  GetNutritionTodayUseCase(this.repository);

  Future<Nutrition> call(String uid, {int? caloriesGoal}) {
    return repository.getNutritionToday(uid, caloriesGoal: caloriesGoal);
  }
}
