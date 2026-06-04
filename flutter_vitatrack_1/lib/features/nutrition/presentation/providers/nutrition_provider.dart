import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/nutrition.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../data/datasources/firestore_nutrition_datasource.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/usecases/get_nutrition_today_usecase.dart';
import '../../domain/usecases/update_water_usecase.dart';
import '../../domain/usecases/add_meal_usecase.dart';
import '../../domain/usecases/delete_meal_usecase.dart';
import '../../domain/usecases/get_nutrition_range_usecase.dart';

// --- DEPENDENCY INJECTION ---
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final ds = FirestoreNutritionDataSource(ref.watch(firestoreServiceProvider));
  return NutritionRepositoryImpl(ds);
});

final getNutritionTodayUseCaseProvider = Provider((ref) => GetNutritionTodayUseCase(ref.watch(nutritionRepositoryProvider)));
final updateWaterUseCaseProvider = Provider((ref) => UpdateWaterUseCase(ref.watch(nutritionRepositoryProvider)));
final addMealUseCaseProvider = Provider((ref) => AddMealUseCase(ref.watch(nutritionRepositoryProvider)));
final deleteMealUseCaseProvider = Provider((ref) => DeleteMealUseCase(ref.watch(nutritionRepositoryProvider)));
final getNutritionRangeUseCaseProvider = Provider((ref) => GetNutritionRangeUseCase(ref.watch(nutritionRepositoryProvider)));
// ----------------------------

class NutritionState {
  final int caloDaNap;
  final int caloMucTieu;
  final int soLyNuoc;
  final List<Map<String, dynamic>> lichSuBuaAn;

  NutritionState({
    required this.caloDaNap,
    required this.caloMucTieu,
    required this.soLyNuoc,
    required this.lichSuBuaAn,
  });

  factory NutritionState.fromEntity(Nutrition e) => NutritionState(
        caloDaNap: e.caloDaNap,
        caloMucTieu: e.caloMucTieu,
        soLyNuoc: e.soLyNuoc,
        lichSuBuaAn: e.lichSuBuaAn,
      );
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  final String? _uid;
  final GetNutritionTodayUseCase _getToday;
  final UpdateWaterUseCase _updateWater;
  final AddMealUseCase _addMeal;
  final DeleteMealUseCase _deleteMeal;

  NutritionNotifier(this._uid, this._getToday, this._updateWater, this._addMeal, this._deleteMeal)
      : super(NutritionState(caloDaNap: 0, caloMucTieu: 0, soLyNuoc: 0, lichSuBuaAn: [])) {
    load();
  }

  Future<void> load() async {
    if (_uid == null) return;
    // We omit explicitly fetching profile here. 
    // The data source will handle fetching the default goal if needed.
    final e = await _getToday(_uid);
    state = NutritionState.fromEntity(e);
  }

  Future<void> uongNuoc() async {
    if (_uid == null) return;
    await _updateWater.increment(_uid);
    await load();
  }

  Future<void> botNuoc() async {
    if (_uid == null) return;
    await _updateWater.decrement(_uid);
    await load();
  }

  Future<void> themMonAn(int calo, double p, double c, double f, {String tenMonAn = 'Bữa ăn thêm'}) async {
    if (_uid == null) return;
    await _addMeal(_uid, calo, p, c, f, tenMonAn: tenMonAn);
    await load();
  }

  Future<void> xoaMonAn(String mealId) async {
    if (_uid == null) return;
    await _deleteMeal(_uid, mealId);
    await load();
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  final uid = ref.watch(nguoiDungHienTaiProvider)?.uid;
  return NutritionNotifier(
    uid,
    ref.watch(getNutritionTodayUseCaseProvider),
    ref.watch(updateWaterUseCaseProvider),
    ref.watch(addMealUseCaseProvider),
    ref.watch(deleteMealUseCaseProvider),
  );
});

final weekNutritionProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final uid = ref.watch(nguoiDungHienTaiProvider)?.uid;
  if (uid == null) return [];
  
  final getRange = ref.watch(getNutritionRangeUseCaseProvider);
  final now = DateTime.now();
  final from = now.subtract(Duration(days: now.weekday - 1));
  final to = from.add(const Duration(days: 6));
  
  return getRange(uid, from, to);
});

final monthNutritionProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final uid = ref.watch(nguoiDungHienTaiProvider)?.uid;
  if (uid == null) return [];
  
  final getRange = ref.watch(getNutritionRangeUseCaseProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, 1);
  final to = DateTime(now.year, now.month + 1, 0); 
  
  return getRange(uid, from, to);
});
