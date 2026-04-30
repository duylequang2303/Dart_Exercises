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
final foodSearchProvider = StateNotifierProvider<FoodSearchNotifier, List<FoodEntity>>((ref) {
  return FoodSearchNotifier(ref.watch(foodApiDataSourceProvider));
});

class FoodSearchNotifier extends StateNotifier<List<FoodEntity>> {
  final FoodApiDataSource _dataSource;
  FoodSearchNotifier(this._dataSource) : super([]);

  bool isLoading = false;

  Future<void> timKiem(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }
    isLoading = true;
    state = await _dataSource.searchFood(query);
    isLoading = false;
  }
}