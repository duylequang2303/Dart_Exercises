import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/nutrition.dart';
import '../../data/datasources/firestore_nutrition_datasource.dart';

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
  final FirestoreNutritionDataSource _datasource;
  final String? _uid;

  NutritionNotifier(this._datasource, this._uid)
      : super(NutritionState(caloDaNap: 0, caloMucTieu: 0, soLyNuoc: 0, lichSuBuaAn: [])) {
    load();
  }

  Future<void> load() async {
    if (_uid == null) return;
    final e = await _datasource.getNutritionToday(_uid!);
    state = NutritionState.fromEntity(e);
  }

  Future<void> uongNuoc() async {
    if (_uid == null) return;
    await _datasource.incrementWater(_uid!);
    await load();
  }

  Future<void> botNuoc() async {
    if (_uid == null) return;
    await _datasource.decrementWater(_uid!);
    await load();
  }

  Future<void> themMonAn(int calo, double p, double c, double f) async {
    if (_uid == null) return;
    await _datasource.addMeal(_uid!, calo, p, c, f);
    await load();
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  final ds = FirestoreNutritionDataSource(ref.watch(firestoreServiceProvider));
  final uid = ref.watch(nguoiDungHienTaiProvider)?.uid;
  return NutritionNotifier(ds, uid);
});
