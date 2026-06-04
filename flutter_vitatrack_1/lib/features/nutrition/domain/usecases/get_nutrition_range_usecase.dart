import '../repositories/nutrition_repository.dart';

class GetNutritionRangeUseCase {
  final NutritionRepository repository;
  GetNutritionRangeUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(String uid, DateTime from, DateTime to) {
    return repository.getNutritionRange(uid, from, to);
  }
}
