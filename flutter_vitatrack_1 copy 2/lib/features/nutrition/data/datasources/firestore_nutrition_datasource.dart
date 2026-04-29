import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/nutrition.dart';
import '../models/meal_model.dart';
import '../models/nutrition_model.dart';

class FirestoreNutritionDataSource {
  final FirestoreService _firestoreService;

  FirestoreNutritionDataSource(this._firestoreService);

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<Nutrition> getNutritionToday(String uid) async {
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';
    final doc = await _firestoreService.getDocument(path, date);

    if (doc == null) {
      final newData = {
        'caloDaNap': 0,
        'caloMucTieu': 2000,
        'soLyNuoc': 0,
        'meals': [],
      };
      await _firestoreService.setDocument(path, date, newData);
      return NutritionModel.fromMock(newData);
    }

    final caloDaNap = doc['caloDaNap'] as int? ?? 0;
    final caloMucTieu = doc['caloMucTieu'] as int? ?? 2000;
    final soLyNuoc = doc['soLyNuoc'] as int? ?? 0;
    final meals = List<Map<String, dynamic>>.from(doc['meals'] ?? []);
    
    return Nutrition(
      caloDaNap: caloDaNap,
      caloMucTieu: caloMucTieu,
      soLyNuoc: soLyNuoc,
      lichSuBuaAn: meals,
    );
  }

  Future<void> incrementWater(String uid) async {
    final nutrition = await getNutritionToday(uid);
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';
    await _firestoreService.updateDocument(path, date, {
      'soLyNuoc': nutrition.soLyNuoc + 1,
    });
  }

  Future<void> decrementWater(String uid) async {
    final nutrition = await getNutritionToday(uid);
    if (nutrition.soLyNuoc > 0) {
      final date = _getTodayDateString();
      final path = 'users/$uid/nutrition';
      await _firestoreService.updateDocument(path, date, {
        'soLyNuoc': nutrition.soLyNuoc - 1,
      });
    }
  }

  Future<void> addMeal(String uid, int calo, double protein, double carb, double fat) async {
    final nutrition = await getNutritionToday(uid);
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';

    final newMeal = MealModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tenMonAn: 'Bữa ăn thêm',
      loaiBuaAn: 'phu',
      calo: calo,
      protein: protein,
      carbs: carb,
      fat: fat,
      uid: uid,
      ngayAn: DateTime.now(),
    ).toFirestore();

    final updatedMeals = List<Map<String, dynamic>>.from(nutrition.lichSuBuaAn)..add(newMeal);

    await _firestoreService.updateDocument(path, date, {
      'caloDaNap': nutrition.caloDaNap + calo,
      'meals': updatedMeals,
    });
  }
}
