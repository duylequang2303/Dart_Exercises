// lib/features/workout/presentation/providers/exercise_search_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/workout_remote_datasource.dart';
import '../../domain/entities/activity_entity.dart';

class ExerciseSearchProvider extends ChangeNotifier {
  final WorkoutRemoteDataSource remoteDataSource;

  List<ActivityEntity> _exercises = [];
  bool _isLoading = false;
  String _currentQuery = '';
  int? _selectedMuscleId;
  String? _errorMessage;

  List<ActivityEntity> get exercises => _exercises;
  bool get isLoading => _isLoading;
  int? get selectedMuscleId => _selectedMuscleId;
  String? get errorMessage => _errorMessage;

  Timer? _debounceTimer;

  ExerciseSearchProvider({required this.remoteDataSource}) {
    fetchExercises();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchExercises() async {
    if (_isLoading) return; // tránh gọi chồng
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await remoteDataSource.searchExercises(
        query: _currentQuery,
        muscleId: _selectedMuscleId,
      );
      _exercises = result;
      if (_exercises.isEmpty && _currentQuery.isEmpty && _selectedMuscleId == null) {
        _errorMessage = 'Không có bài tập nào. Hãy thử lại sau.';
      }
    } catch (e) {
      _errorMessage = e.toString();
      _exercises = [];
      debugPrint('Lỗi fetchExercises: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateQuery(String query) {
    if (_currentQuery == query) return;
    _currentQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchExercises();
    });
  }

  void updateMuscleFilter(int? muscleId) {
    if (_selectedMuscleId == muscleId) return;
    _selectedMuscleId = muscleId;
    _debounceTimer?.cancel();
    fetchExercises();
  }

  void clearFilters() {
    if (_currentQuery.isEmpty && _selectedMuscleId == null) return;
    _currentQuery = '';
    _selectedMuscleId = null;
    _debounceTimer?.cancel();
    fetchExercises();
  }

  Future<void> refresh() async {
    await fetchExercises();
  }
}