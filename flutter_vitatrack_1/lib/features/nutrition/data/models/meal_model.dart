import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_vitatrack_1/features/nutrition/domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  MealModel({
    required super.id,
    required super.tenMonAn,
    required super.loaiBuaAn,
    required super.calo,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.ngayAn,
    required super.uid,
  });

  factory MealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealModel(
      id: doc.id,
      tenMonAn: data['tenMonAn'] ?? '',
      loaiBuaAn: data['loaiBuaAn'] ?? 'phu',
      calo: data['calo'] ?? 0,
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
      ngayAn: (data['ngayAn'] as Timestamp).toDate(),
      uid: data['uid'] ?? '',
    );
  }

  factory MealModel.fromMock(Map<String, dynamic> mock) {
    return MealModel(
      id: mock['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      tenMonAn: mock['ten'] ?? mock['tenMonAn'] ?? '',
      loaiBuaAn: mock['loai'] ?? mock['loaiBuaAn'] ?? 'phu',
      calo: mock['calo'] ?? 0,
      protein: (mock['protein'] ?? 0).toDouble(),
      carbs: (mock['carbs'] ?? 0).toDouble(),
      fat: (mock['fat'] ?? 0).toDouble(),
      ngayAn: DateTime.now(),
      uid: mock['uid'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tenMonAn': tenMonAn,
      'loaiBuaAn': loaiBuaAn,
      'calo': calo,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ngayAn': Timestamp.fromDate(ngayAn),
      'uid': uid,
    };
  }
}