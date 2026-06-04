import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/providers/dio_provider.dart';
import '../../domain/entities/food_entity.dart';
import '../../data/datasources/food_api_datasource.dart';


// Khởi tạo Datasource provider
final foodApiDataSourceProvider = Provider<FoodApiDataSource>((ref) {
  return FoodApiDataSource(ref.watch(dioProvider));
});

// Provider quản lý danh sách kết quả tìm kiếm
final foodSearchProvider = StateNotifierProvider<FoodSearchNotifier, AsyncValue<List<FoodEntity>>>((ref) {
  return FoodSearchNotifier(ref.watch(foodApiDataSourceProvider));
});

class FoodSearchNotifier extends StateNotifier<AsyncValue<List<FoodEntity>>> {
  final FoodApiDataSource _dataSource;

  Timer? _debounce;
  CancelToken? _cancelToken;

  FoodSearchNotifier(this._dataSource) : super(const AsyncValue.data([]));

  Future<void> timKiem(String query) async {
    _debounce?.cancel();

    if (query.isEmpty) {
      _cancelToken?.cancel('Người dùng xóa hết từ khóa');
      state = const AsyncValue.data([]);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      _cancelToken?.cancel('Request mới gửi đi');
      _cancelToken = CancelToken();

      state = const AsyncValue.loading();
      try {
        // Bước 1: Tìm trên OpenFoodFacts trước
        final results = await _dataSource.searchFood(query, cancelToken: _cancelToken);

        if (_cancelToken?.isCancelled ?? false) return;

        if (results.isNotEmpty) {
          // Có kết quả từ database thực → dùng luôn
          state = AsyncValue.data(results);
        } else {
          // Không có kết quả → Fallback AI ước tính dinh dưỡng
          final groqKey = dotenv.env['GROQ_API_KEY'] ?? '';
          final aiResults = await _dataSource.estimateByAI(query, groqKey);
          state = AsyncValue.data(aiResults);
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) return;
        state = AsyncValue.error(e, StackTrace.current);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel('Provider disposed');
    super.dispose();
  }
}