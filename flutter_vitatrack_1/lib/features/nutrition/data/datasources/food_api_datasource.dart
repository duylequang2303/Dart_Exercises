import 'package:dio/dio.dart';
import '../../domain/entities/food_entity.dart';

class FoodApiDataSource {
  final Dio _dio;

  // Inject Dio qua constructor theo yêu cầu
  FoodApiDataSource(this._dio);

  Future<List<FoodEntity>> searchFood(String query) async {
    final url = 'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&json=true&page_size=20';
    
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List products = response.data['products'] ?? [];
        
        return products
            .map((item) => FoodEntity.fromJson(item))
            // LƯU Ý: Bỏ qua item nếu thiếu calo (calo <= 0)
            .where((food) => food.calo > 0)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}