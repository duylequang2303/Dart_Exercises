import '../repositories/nutrition_repository.dart';

class AddMealUseCase {
  final NutritionRepository repository;
  AddMealUseCase(this.repository);

  Future<void> call(String uid, int calo, double protein, double carb, double fat, {String tenMonAn = 'Bữa ăn thêm'}) {
    return repository.addMeal(uid, calo, protein, carb, fat, tenMonAn: tenMonAn);
  }
}
