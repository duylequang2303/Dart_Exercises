class MealEntity {
  final String id;
  final String tenMonAn;
  final String loaiBuaAn;
  final int calo;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime ngayAn;
  final String uid;

  MealEntity({
    required this.id,
    required this.tenMonAn,
    required this.loaiBuaAn,
    required this.calo,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ngayAn,
    required this.uid,
  });

  double get tongMacroGram => protein + carbs + fat;

  MealEntity copyWith({
    String? id,
    String? tenMonAn,
    String? loaiBuaAn,
    int? calo,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? ngayAn,
    String? uid,
  }) {
    return MealEntity(
      id: id ?? this.id,
      tenMonAn: tenMonAn ?? this.tenMonAn,
      loaiBuaAn: loaiBuaAn ?? this.loaiBuaAn,
      calo: calo ?? this.calo,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      ngayAn: ngayAn ?? this.ngayAn,
      uid: uid ?? this.uid,
    );
  }
}
