import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_analysis.dart';
import '../../domain/entities/coach_plan.dart';
import '../../domain/entities/user_health_context.dart';
import 'ai_coach_dependencies_provider.dart';
import '../../../health/presentation/providers/health_provider.dart';
import '../../../nutrition/presentation/providers/nutrition_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// ─── Health Context THẬT ──────────────────────────────────────

final userHealthContextProvider = Provider<UserHealthContext>((ref) {
  final health = ref.watch(healthProvider);
  final nutrition = ref.watch(nutritionProvider);
  final profile = ref.watch(profileProvider).profile;

  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;
  for (final meal in nutrition.lichSuBuaAn) {
    totalProtein += (meal['protein'] as num?)?.toDouble() ?? 0;
    totalCarbs += (meal['carbs'] as num?)?.toDouble() ?? 0;
    totalFat += (meal['fat'] as num?)?.toDouble() ?? 0;
  }

  return UserHealthContext(
    stepsToday: health.steps,
    heartRateBpm: health.heartRate,
    sleepHours: health.sleepHours,
    dailyStepsGoal: 10000,
    caloriesBurned: nutrition.caloDaNap,
    dailyCaloriesGoal: nutrition.caloMucTieu > 0
        ? nutrition.caloMucTieu
        : 2000,
    waterIntakeMl: nutrition.soLyNuoc * 250,
    dailyWaterGoalMl: 2500,
    proteinGram: totalProtein,
    carbsGram: totalCarbs,
    fatGram: totalFat,
    tuoi: profile?.tuoi,
    chieuCao: profile?.chieuCao,
    canNang: profile?.canNang,
    gioiTinh: profile?.gioiTinh,
    mucTieu: profile?.mucTieu,
    cuongDo: profile?.cuongDo,
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
    final context = ref.read(userHealthContextProvider);
    final useCase = ref.read(getHealthAnalysisUseCaseProvider);
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
    Future.microtask(() => fetchPlan());
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
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleTask(String taskId) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final taskIndex =
        currentPlan.dailyTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final currentTask = currentPlan.dailyTasks[taskIndex];
    final newIsCompleted = !currentTask.isCompleted;

    final updatedTasks = List.of(currentPlan.dailyTasks);
    updatedTasks[taskIndex] = currentTask.copyWith(isCompleted: newIsCompleted);

    state = state.copyWith(
      plan: CoachPlan(
        dailyTasks: updatedTasks,
        weeklyGoals: currentPlan.weeklyGoals,
      ),
    );

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