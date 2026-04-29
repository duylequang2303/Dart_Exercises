import '../entities/nutrition.dart';
import '../repositories/nutrition_repository.dart';

class GetDailyNutrition {
  final NutritionRepository repository;
  GetDailyNutrition(this.repository);

  Future<Nutrition> call() async {
    return repository.getDailyNutrition();
  }
}
