import '../../domain/entities/nutrition.dart';

class NutritionModel extends Nutrition {
  NutritionModel({required super.caloDaNap, required super.caloMucTieu, required super.soLyNuoc, required super.lichSuBuaAn});

  factory NutritionModel.fromMock(dynamic mock) => NutritionModel(
      caloDaNap: mock.caloDaNap ?? mock.caloNap ?? 0,
      caloMucTieu: mock.caloMucTieu ?? 0,
      soLyNuoc: mock.soLyNuoc ?? mock.lyNuoc ?? 0,
      lichSuBuaAn: List<Map<String, dynamic>>.from(mock.lichSuBuaAn ?? mock.mealHistory ?? []),
    );
}
