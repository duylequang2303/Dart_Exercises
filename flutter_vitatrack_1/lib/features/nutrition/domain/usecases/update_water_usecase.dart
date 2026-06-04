import '../repositories/nutrition_repository.dart';

class UpdateWaterUseCase {
  final NutritionRepository repository;
  UpdateWaterUseCase(this.repository);

  Future<void> increment(String uid) {
    return repository.incrementWater(uid);
  }

  Future<void> decrement(String uid) {
    return repository.decrementWater(uid);
  }
}
