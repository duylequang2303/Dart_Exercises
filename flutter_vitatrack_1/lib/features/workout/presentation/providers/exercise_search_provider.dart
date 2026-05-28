import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/search_exercises.dart';
import '../../domain/entities/activity_entity.dart';
import 'workout_timer_provider.dart';

class ExerciseSearchState {
  final List<ActivityEntity> exercises;
  final bool isLoading;
  final String currentQuery;
  final int? selectedMuscleId;
  final String? errorMessage;

  ExerciseSearchState({
    this.exercises = const [],
    this.isLoading = false,
    this.currentQuery = '',
    this.selectedMuscleId,
    this.errorMessage,
  });
}

class ExerciseSearchNotifier extends StateNotifier<ExerciseSearchState> {
  final SearchExercises _searchExercises;
  Timer? _debounceTimer;

  ExerciseSearchNotifier(this._searchExercises) : super(ExerciseSearchState()) {
    fetchExercises();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchExercises() async {
    if (state.isLoading) return;
    state = ExerciseSearchState(
      exercises: state.exercises,
      isLoading: true,
      currentQuery: state.currentQuery,
      selectedMuscleId: state.selectedMuscleId,
      errorMessage: null,
    );

    try {
      final result = await _searchExercises.execute(
        query: state.currentQuery,
        muscleId: state.selectedMuscleId,
      );
      
      String? newError;
      if (result.isEmpty && state.currentQuery.isEmpty && state.selectedMuscleId == null) {
        newError = 'Không có bài tập nào. Hãy thử lại sau.';
      }
      
      state = ExerciseSearchState(
        exercises: result,
        isLoading: false,
        currentQuery: state.currentQuery,
        selectedMuscleId: state.selectedMuscleId,
        errorMessage: newError,
      );
    } catch (e) {
      state = ExerciseSearchState(
        exercises: const [],
        isLoading: false,
        currentQuery: state.currentQuery,
        selectedMuscleId: state.selectedMuscleId,
        errorMessage: e.toString(),
      );
    }
  }

  void updateQuery(String query) {
    if (state.currentQuery == query) return;
    state = ExerciseSearchState(
      exercises: state.exercises,
      isLoading: state.isLoading,
      currentQuery: query,
      selectedMuscleId: state.selectedMuscleId,
      errorMessage: state.errorMessage,
    );
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchExercises();
    });
  }

  void updateMuscleFilter(int? muscleId) {
    if (state.selectedMuscleId == muscleId) return;
    state = ExerciseSearchState(
      exercises: state.exercises,
      isLoading: state.isLoading,
      currentQuery: state.currentQuery,
      selectedMuscleId: muscleId,
      errorMessage: state.errorMessage,
    );
    _debounceTimer?.cancel();
    fetchExercises();
  }

  void clearFilters() {
    if (state.currentQuery.isEmpty && state.selectedMuscleId == null) return;
    state = ExerciseSearchState(
      exercises: state.exercises,
      isLoading: state.isLoading,
      currentQuery: '',
      selectedMuscleId: null,
      errorMessage: state.errorMessage,
    );
    _debounceTimer?.cancel();
    fetchExercises();
  }
}

final exerciseSearchProvider = StateNotifierProvider<ExerciseSearchNotifier, ExerciseSearchState>((ref) {
  final usecase = ref.watch(searchExercisesUseCaseProvider);
  return ExerciseSearchNotifier(usecase);
});