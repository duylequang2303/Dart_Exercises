// lib/features/workout/presentation/providers/exercise_search_provider.dart
import 'package:flutter/material.dart';
import '../../data/datasources/workout_remote_datasource.dart';
import '../../domain/entities/exercise_entity.dart'; // Import đúng Entity

class ExerciseSearchProvider extends ChangeNotifier {
  final WorkoutRemoteDatasource remoteDataSource;

  ExerciseSearchProvider({required this.remoteDataSource});

  // Trạng thái lưu trữ nội bộ
  List<ExerciseEntity> _exercises = []; // Đổi kiểu dữ liệu từ ActivityEntity sang ExerciseEntity
  List<ExerciseEntity> get exercises => _exercises;

  String _currentQuery = '';
  int? _selectedMuscleId; // Giữ nguyên int? nếu ID danh mục bài tập của bạn là số
  
  bool _isLoading = false;
  String? _errorMessage;

  // ... Các hàm getter/setter khác của bạn ...

  Future<void> fetchExercises() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // FIX LỖI 1: Chuyển đổi int? sang String? bằng cách sử dụng .toString() nếu có giá trị
      final String? muscleIdParam = _selectedMuscleId?.toString();

      final result = await remoteDataSource.searchExercises(
        query: _currentQuery,
        muscleId: muscleIdParam, 
      );

      // FIX LỖI 2: Vì ExerciseModel kế thừa ExerciseEntity, ta có thể gán trực tiếp hoặc cast rõ ràng
      _exercises = result; 
      
      if (_exercises.isEmpty && _currentQuery.isEmpty && _selectedMuscleId == null) {
        _errorMessage = 'Không có bài tập nào. Hãy thử lại sau.';
      }
    } catch (e) {
      _errorMessage = e.toString();
      _exercises = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}