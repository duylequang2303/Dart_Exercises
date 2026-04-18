import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/nutrition.dart';
import '../../domain/usecases/get_daily_nutrition.dart';
import '../../data/datasources/mock_nutrition_datasource.dart';
import '../../data/repositories/nutrition_repository_impl.dart';

class NutritionState {
  final int caloDaNap;
  final int caloMucTieu;
  final int soLyNuoc;
  final List<Map<String, dynamic>> lichSuBuaAn;

  NutritionState({required this.caloDaNap, required this.caloMucTieu, required this.soLyNuoc, required this.lichSuBuaAn});

  factory NutritionState.fromEntity(Nutrition e) => NutritionState(
        caloDaNap: e.caloDaNap,
        caloMucTieu: e.caloMucTieu,
        soLyNuoc: e.soLyNuoc,
        lichSuBuaAn: e.lichSuBuaAn,
      );
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  final GetDailyNutrition _usecase;
  final MockNutritionDataSource _dataSource;

  NutritionNotifier(this._usecase, this._dataSource)
      : super(NutritionState(caloDaNap: 0, caloMucTieu: 0, soLyNuoc: 0, lichSuBuaAn: [])) {
    load();
  }

  Future<void> load() async {
    final e = await _usecase.call();
    state = NutritionState.fromEntity(e);
  }

  void uongNuoc() {
    _dataSource.incrementWater();
    load();
  }

  void botNuoc() {
    _dataSource.decrementWater();
    load();
  }

  void themMonAn(int calo, double p, double c, double f) {
    _dataSource.addMeal(calo, p, c, f);
    load();
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  final ds = MockNutritionDataSource();
  final repo = NutritionRepositoryImpl(datasource: ds);
  final usecase = GetDailyNutrition(repo);
  return NutritionNotifier(usecase, ds);
});
