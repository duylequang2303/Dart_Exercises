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

// Provider quản lý danh sách kết quả tìm kiếm với AsyncValue để có loading/error
final foodSearchProvider = StateNotifierProvider<FoodSearchNotifier, AsyncValue<List<FoodEntity>>>((ref) {
  return FoodSearchNotifier(ref.watch(foodApiDataSourceProvider));
});

class FoodSearchNotifier extends StateNotifier<AsyncValue<List<FoodEntity>>> {
  final FoodApiDataSource _dataSource;
  Timer? _debounce;

  FoodSearchNotifier(this._dataSource) : super(const AsyncValue.data([]));

  void timKiem(String query) {
    // Hủy timer cũ nếu có (Debounce)
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Đợi 500ms sau khi người dùng ngừng gõ mới gọi API
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }
      
      state = const AsyncValue.loading();
      try {
        final result = await _dataSource.searchFood(query);
        state = AsyncValue.data(result);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}