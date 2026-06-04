import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_analysis.dart';
import '../../domain/entities/coach_plan.dart';
import '../../domain/entities/user_health_context.dart';
import 'ai_coach_dependencies_provider.dart';
import 'package:flutter_vitatrack_1/features/health/presentation/providers/health_provider.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:flutter_vitatrack_1/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';

// ─── Health Context (từ data thật) ───────────────────────────

final userHealthContextProvider = Provider<UserHealthContext>((ref) {
  final health = ref.watch(healthProvider);
  final nutrition = ref.watch(nutritionProvider);
  final profile = ref.watch(profileProvider).profile;

  // Tính tổng macro từ lịch sử bữa ăn
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;
  for (final meal in nutrition.lichSuBuaAn) {
    totalProtein += (meal['protein'] as num?)?.toDouble() ?? 0;
    totalCarbs += (meal['carbs'] as num?)?.toDouble() ?? 0;
    totalFat += (meal['fat'] as num?)?.toDouble() ?? 0;
  }

  int dailyCaloriesGoal = (profile?.caloriesGoal != null && profile!.caloriesGoal! > 0)
      ? profile.caloriesGoal!
      : (nutrition.caloMucTieu > 0 ? nutrition.caloMucTieu : 2000);
  
  final historyAsync = ref.watch(workoutHistoryProvider);
  final workouts = historyAsync.value ?? [];
  final now = DateTime.now();
  
  int calBurned = 0;
  for (final w in workouts) {
    if (w.date.year == now.year && w.date.month == now.month && w.date.day == now.day) {
      calBurned += w.calories.toInt();
    }
  }

  return UserHealthContext(
    stepsToday: health.steps,
    caloriesBurned: nutrition.caloDaNap,
    activeCaloriesBurned: calBurned,
    waterIntakeMl: nutrition.soLyNuoc * 250,
    sleepHours: health.sleepHours == 0.0 ? 7.5 : health.sleepHours,
    dailyStepsGoal: 10000,
    dailyCaloriesGoal: dailyCaloriesGoal,
    dailyWaterGoalMl: 2500,
    // Profile từ onboarding
    mucTieu: profile?.mucTieu,
    gioiTinh: profile?.gioiTinh,
    chieuCao: profile?.chieuCao,
    canNang: profile?.canNang,
    cuongDo: profile?.cuongDo,
    tuoi: profile?.tuoi,
    // Macro hôm nay
    proteinGram: totalProtein,
    carbsGram: totalCarbs,
    fatGram: totalFat,
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
    final aiResult = await useCase.execute(context);
    
    // Tính toán weeklyActivity thật từ lịch sử
    final historyAsync = ref.read(workoutHistoryProvider);
    final workouts = historyAsync.value ?? [];
    final now = DateTime.now();
    final Map<String, int> realActivity = {};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final weekdayStr = switch (date.weekday) {
        1 => 'T2', 2 => 'T3', 3 => 'T4', 4 => 'T5',
        5 => 'T6', 6 => 'T7', 7 => 'CN', _ => ''
      };
      
      double cal = 0;
      for (var w in workouts) {
        if (w.date.year == date.year && w.date.month == date.month && w.date.day == date.day) {
          cal += w.calories;
        }
      }
      
      // Giả sử mục tiêu đốt 300 kcal = 100%
      int percent = ((cal / 300.0) * 100).toInt().clamp(0, 100);
      realActivity[weekdayStr] = percent;
    }

    return HealthAnalysis(
      summary: aiResult.summary,
      diemTot: aiResult.diemTot,
      canCaiThien: aiResult.canCaiThien,
      bmiDanhGia: aiResult.bmiDanhGia,
      sleepQualityChange: aiResult.sleepQualityChange,
      waterIntake: aiResult.waterIntake,
      waterRemaining: aiResult.waterRemaining,
      caloriesBurned: aiResult.caloriesBurned,
      caloriesGoalPercent: aiResult.caloriesGoalPercent,
      weeklyActivity: realActivity,
    );
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