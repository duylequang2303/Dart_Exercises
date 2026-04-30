import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_analysis.dart';
import '../../domain/entities/coach_plan.dart';
import '../../domain/entities/user_health_context.dart';
import 'ai_coach_dependencies_provider.dart';

// ─── Health Context (mock) ────────────────────────────────────
// TODO: Thay bằng provider thực từ health/activity feature

final userHealthContextProvider = Provider<UserHealthContext>((ref) {
  return const UserHealthContext(
    stepsToday: 8290,
    caloriesBurned: 450,
    waterIntakeMl: 1800,
    sleepHours: 7.5,
    heartRateBpm: 72,
    dailyStepsGoal: 10000,
    dailyCaloriesGoal: 700,
    dailyWaterGoalMl: 2500,
  );
});

// ─── Health Analysis ──────────────────────────────────────────

final healthAnalysisProvider =
    AsyncNotifierProvider<HealthAnalysisNotifier, HealthAnalysis>(
  HealthAnalysisNotifier.new,
);

class HealthAnalysisNotifier extends AsyncNotifier<HealthAnalysis> {
  @override
  Future<HealthAnalysis> build() async {
    return _fetchAnalysis();
  }

  Future<HealthAnalysis> _fetchAnalysis() async {
    final useCase = ref.read(getHealthAnalysisUseCaseProvider);
    final context = ref.read(userHealthContextProvider);
    return useCase.execute(context);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchAnalysis);
  }
}

// ─── Coach Plan State ─────────────────────────────────────────

class CoachPlanState {
  final CoachPlan? plan;
  final bool isLoading;
  final String? errorMessage;

  const CoachPlanState({
    this.plan,
    this.isLoading = false,
    this.errorMessage,
  });

  CoachPlanState copyWith({
    CoachPlan? plan,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CoachPlanState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─── Coach Plan Notifier ──────────────────────────────────────

class CoachPlanNotifier extends StateNotifier<CoachPlanState> {
  final Ref _ref;

  CoachPlanNotifier(this._ref) : super(const CoachPlanState()) {
    fetchPlan();
  }

  Future<void> fetchPlan() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final useCase = _ref.read(getCoachPlanUseCaseProvider);
      final context = _ref.read(userHealthContextProvider);
      final plan = await useCase.execute(context);
      state = state.copyWith(plan: plan, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải kế hoạch. Vui lòng thử lại.',
      );
    }
  }

  Future<void> toggleTask(String taskId) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final taskIndex = currentPlan.dailyTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final currentTask = currentPlan.dailyTasks[taskIndex];
    final newIsCompleted = !currentTask.isCompleted;

    // Cập nhật UI ngay lập tức
    final updatedTasks = List.of(currentPlan.dailyTasks);
    updatedTasks[taskIndex] = currentTask.copyWith(isCompleted: newIsCompleted);

    state = state.copyWith(
      plan: CoachPlan(
        dailyTasks: updatedTasks,
        weeklyGoals: currentPlan.weeklyGoals,
      ),
    );

    // Lưu local, rollback nếu lỗi
    try {
      final useCase = _ref.read(updateTaskCompletionUseCaseProvider);
      await useCase.execute(taskId: taskId, isCompleted: newIsCompleted);
    } catch (e) {
      state = state.copyWith(plan: currentPlan);
    }
  }

  void dismissError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ─── Provider ─────────────────────────────────────────────────

final coachPlanProvider =
    StateNotifierProvider<CoachPlanNotifier, CoachPlanState>((ref) {
  return CoachPlanNotifier(ref);
});