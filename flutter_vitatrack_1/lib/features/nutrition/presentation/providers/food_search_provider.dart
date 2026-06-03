import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/food_entity.dart';
import '../../data/datasources/food_api_datasource.dart';

// Khởi tạo Dio provider
final dioProvider = Provider<Dio>((ref) => Dio());

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
    // Hủy debounce cũ (người dùng vẫn đang gõ)
    _debounce?.cancel();

    if (query.isEmpty) {
      _cancelToken?.cancel('Người dùng xóa hết từ khóa');
      state = const AsyncValue.data([]);
      return;
    }

    // Chờ 500ms sau ký tự cuối cùng mới gửi request
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      // Hủy request đang chạy dở (nếu có) để tránh race condition
      _cancelToken?.cancel('Request mới gửi đi');
      _cancelToken = CancelToken();

      state = const AsyncValue.loading();
      try {
        final results = await _dataSource.searchFood(query, cancelToken: _cancelToken);
        if (!(_cancelToken?.isCancelled ?? false)) {
          state = AsyncValue.data(results);
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) return; // Request bị hủy - bỏ qua
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