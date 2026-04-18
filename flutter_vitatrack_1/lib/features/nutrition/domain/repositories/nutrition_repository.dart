import '../entities/nutrition.dart';

abstract class NutritionRepository {
  Future<Nutrition> getDailyNutrition();
}
