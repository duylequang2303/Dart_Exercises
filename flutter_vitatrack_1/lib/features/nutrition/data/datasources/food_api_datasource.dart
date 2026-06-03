import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/food_entity.dart';

class FoodApiDataSource {
  final Dio _dio;

  FoodApiDataSource(this._dio);

  Future<List<FoodEntity>> searchFood(String query, {CancelToken? cancelToken}) async {
    final url = 'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&json=true&page_size=20';

    try {
      final response = await _dio.get(url, cancelToken: cancelToken);
      if (response.statusCode == 200) {
        final List products = response.data['products'] ?? [];
        final results = products
            .map((item) => FoodEntity.fromJson(item))
            .where((food) => food.calo > 0)
            .toList();
        return results;
      }
      return [];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Dùng Groq AI để ước tính dinh dưỡng khi OpenFoodFacts không có kết quả
  Future<List<FoodEntity>> estimateByAI(String query, String groqApiKey) async {
    if (groqApiKey.isEmpty) return [];
    try {
      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $groqApiKey',
          },
        ),
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': '''Ước tính thông tin dinh dưỡng cho món ăn: "$query".
Trả về ĐÚNG định dạng JSON sau, không thêm text nào khác:
[
  {
    "tenMonAn": "Tên đầy đủ của món",
    "calo": 200,
    "protein": 10.0,
    "carbs": 25.0,
    "fat": 5.0
  }
]
Lưu ý: ước tính cho 100g hoặc 1 khẩu phần thông thường. Có thể trả về 1-3 biến thể nếu cần.''',
            }
          ],
          'temperature': 0.2,
          'max_tokens': 500,
        },
      );

      if (response.statusCode != 200) return [];

      final choices = response.data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return [];

      final text = choices[0]['message']?['content'] as String? ?? '';

      // Trích xuất JSON array
      final start = text.indexOf('[');
      final end = text.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) return [];

      final jsonStr = text.substring(start, end + 1);
      final dynamic parsed = jsonDecode(jsonStr);
      if (parsed is! List) return [];

      return parsed.map((item) {
        final map = item as Map<String, dynamic>;
        return FoodEntity(
          tenMonAn: map['tenMonAn'] as String? ?? query,
          calo: (map['calo'] as num?)?.toInt() ?? 0,
          protein: (map['protein'] as num?)?.toDouble() ?? 0,
          carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
          fat: (map['fat'] as num?)?.toDouble() ?? 0,
          hinhAnh: null,
        );
      }).where((f) => f.calo > 0).toList();
    } catch (e) {
      return [];
    }
  }
}