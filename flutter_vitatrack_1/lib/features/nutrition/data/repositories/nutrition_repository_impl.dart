import '../../domain/entities/nutrition.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/firestore_nutrition_datasource.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final FirestoreNutritionDataSource remoteDataSource;

  NutritionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Nutrition> getNutritionToday(String uid, {int? caloriesGoal}) {
    return remoteDataSource.getNutritionToday(uid, caloriesGoal: caloriesGoal);
  }

  @override
  Future<void> incrementWater(String uid) {
    return remoteDataSource.incrementWater(uid);
  }

  @override
  Future<void> decrementWater(String uid) {
    return remoteDataSource.decrementWater(uid);
  }

  @override
  Future<void> addMeal(String uid, int calo, double protein, double carb, double fat, {String tenMonAn = 'Bữa ăn thêm'}) {
    return remoteDataSource.addMeal(uid, calo, protein, carb, fat, tenMonAn: tenMonAn);
  }

  @override
  Future<void> deleteMeal(String uid, String mealId) {
    return remoteDataSource.deleteMeal(uid, mealId);
  }

  @override
  Future<List<Map<String, dynamic>>> getNutritionRange(String uid, DateTime from, DateTime to) {
    return remoteDataSource.getNutritionRange(uid, from, to);
  }
}
