import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/nutrition.dart';
import '../models/nutrition_model.dart';

class FirestoreNutritionDataSource {
  final FirestoreService _firestoreService;

  FirestoreNutritionDataSource(this._firestoreService);

  /// Exposed so callers can reuse the same [FirestoreService] instance.
  FirestoreService get firestoreService => _firestoreService;

  String _getTodayDateString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<int> getCaloriesGoalFromProfile(String uid) async {
    try {
      final doc = await _firestoreService.getDocument('users/$uid/profile', 'info');
      if (doc != null && doc['caloriesGoal'] != null) {
        return (doc['caloriesGoal'] as num).toInt();
      }
    } catch (e) {
      // Ignore and fallback to 2000
    }
    return 2000;
  }

  Future<Nutrition> getNutritionToday(String uid, {int? caloriesGoal}) async {
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';
    final doc = await _firestoreService.getDocument(path, date);

    if (doc == null) {
      final goal = caloriesGoal ?? await getCaloriesGoalFromProfile(uid);
      final newData = {
        'caloDaNap': 0,
        'caloMucTieu': goal,
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
    await getNutritionToday(uid); // Ensure document exists
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';
    await _firestoreService.updateDocument(path, date, {
      'soLyNuoc': FieldValue.increment(1),
    });
  }

  Future<void> decrementWater(String uid) async {
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';
    final docRef = _firestoreService.instance.collection(path).doc(date);

    await _firestoreService.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final soLyNuoc = doc.data()?['soLyNuoc'] as int? ?? 0;
      if (soLyNuoc > 0) {
        transaction.update(docRef, {
          'soLyNuoc': FieldValue.increment(-1),
        });
      }
    });
  }

  Future<void> addMeal(
    String uid,
    int calo,
    double protein,
    double carb,
    double fat, {
    String tenMonAn = 'Bữa ăn thêm',
  }) async {
    await getNutritionToday(uid); // Ensure document exists
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';

    final newMeal = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'tenMonAn': tenMonAn,
      'loaiBuaAn': 'phu',
      'calo': calo,
      'protein': double.parse(protein.toStringAsFixed(1)),
      'carbs': double.parse(carb.toStringAsFixed(1)),
      'fat': double.parse(fat.toStringAsFixed(1)),
      'ngayAn': DateTime.now().toIso8601String(),
    };

    await _firestoreService.updateDocument(path, date, {
      'caloDaNap': FieldValue.increment(calo),
      'meals': FieldValue.arrayUnion([newMeal]),
    });
  }

  Future<void> deleteMeal(String uid, String mealId) async {
    final date = _getTodayDateString();
    final path = 'users/$uid/nutrition';
    final docRef = _firestoreService.instance.collection(path).doc(date);

    await _firestoreService.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final meals = List<Map<String, dynamic>>.from(doc.data()?['meals'] ?? []);
      int mealCalo = 0;
      bool deleted = false;
      
      final updatedMeals = meals.where((m) {
        final currentId = m['id']?.toString();
        if (!deleted && currentId == mealId) {
          mealCalo = (m['calo'] as num?)?.toInt() ?? 0;
          deleted = true;
          return false;
        }
        return true;
      }).toList();

      if (deleted) {
        transaction.update(docRef, {
          'caloDaNap': FieldValue.increment(-mealCalo),
          'meals': updatedMeals,
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getNutritionRange(String uid, DateTime from, DateTime to) async {
    final results = <Map<String, dynamic>>[];
    final path = 'users/$uid/nutrition';
    
    // Create a date without time to safely iterate
    var current = DateTime(from.year, from.month, from.day);
    final endDate = DateTime(to.year, to.month, to.day);
    
    while (!current.isAfter(endDate)) {
      final dateStr = "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";
      final doc = await _firestoreService.getDocument(path, dateStr);

      if (doc != null) {
        final meals = List<Map<String, dynamic>>.from(doc['meals'] ?? []);
        double protein = 0, carbs = 0, fat = 0;
        for (final m in meals) {
          protein += (m['protein'] as num?)?.toDouble() ?? 0;
          carbs += (m['carbs'] as num?)?.toDouble() ?? 0;
          fat += (m['fat'] as num?)?.toDouble() ?? 0;
        }
        results.add({
          'date': dateStr,
          'calo': (doc['caloDaNap'] as num?)?.toInt() ?? 0,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'meals': meals,
        });
      } else {
        results.add({
          'date': dateStr,
          'calo': 0,
          'protein': 0.0,
          'carbs': 0.0,
          'fat': 0.0,
          'meals': [],
        });
      }
      current = current.add(const Duration(days: 1));
    }
    return results;
  }
}
