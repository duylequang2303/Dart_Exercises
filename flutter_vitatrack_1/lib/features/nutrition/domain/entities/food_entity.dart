class FoodEntity {
  final String tenMonAn;
  final int calo;
  final double protein;
  final double carbs;
  final double fat;
  final String? hinhAnh;

  FoodEntity({
    required this.tenMonAn,
    required this.calo,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.hinhAnh,
  });

  factory FoodEntity.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] ?? {};
    return FoodEntity(
      tenMonAn: json['product_name'] ?? 'Không tên',
      // Lấy calo (kcal), mặc định 0 nếu không có
      calo: (nutriments['energy-kcal_100g'] ?? 0).toInt(),
      protein: (nutriments['proteins_100g'] ?? 0.0).toDouble(),
      carbs: (nutriments['carbohydrates_100g'] ?? 0.0).toDouble(),
      fat: (nutriments['fat_100g'] ?? 0.0).toDouble(),
      hinhAnh: json['image_url'],
    );
  }
}