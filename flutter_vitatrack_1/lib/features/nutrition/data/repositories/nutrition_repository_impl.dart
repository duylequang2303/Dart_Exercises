import '../../domain/entities/nutrition.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/mock_nutrition_datasource.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final MockNutritionDataSource datasource;
  NutritionRepositoryImpl({required this.datasource});

  @override
  Future<Nutrition> getDailyNutrition() async {
    final model = await datasource.fetchDailyNutrition();
    return model; // NutritionModel extends Nutrition
  }
}
