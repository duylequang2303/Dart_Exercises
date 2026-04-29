import 'package:flutter_vitatrack_1/services/mock_data_service.dart';
import '../models/nutrition_model.dart';

class MockNutritionDataSource {
  final MockDataService _svc = MockDataService.instance;

  Future<NutritionModel> fetchDailyNutrition() async {
    // immediate wrap of current mock state
    return NutritionModel.fromMock(_svc);
  }

  // mutation helpers
  void incrementWater() => _svc.uongNuoc();
  void decrementWater() => _svc.botNuoc();
  void addMeal(int calo, double p, double c, double f) => _svc.themMonAn(calo, p, c, f);
}
