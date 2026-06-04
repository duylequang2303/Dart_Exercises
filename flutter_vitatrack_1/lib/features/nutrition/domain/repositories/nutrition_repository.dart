import '../entities/nutrition.dart';

abstract class NutritionRepository {
  Future<Nutrition> getNutritionToday(String uid, {int? caloriesGoal});
  Future<void> incrementWater(String uid);
  Future<void> decrementWater(String uid);
  Future<void> addMeal(String uid, int calo, double protein, double carb, double fat, {String tenMonAn = 'Bữa ăn thêm'});
  Future<void> deleteMeal(String uid, String mealId);
  Future<List<Map<String, dynamic>>> getNutritionRange(String uid, DateTime from, DateTime to);
}
