import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/health/presentation/providers/health_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class LiveWorkoutState {
  /// Loại bài tập có tính theo bước chân không (chạy/đi bộ)
  final bool isStepBased;

  final int activeSteps;
  final bool isPaused;

  const LiveWorkoutState({
    this.isStepBased = false,
    this.activeSteps = 0,
    this.isPaused = false,
  });

  /// Số bước chân đã đi trong lúc tập (không tính lúc tạm dừng)
  int get stepsDelta => activeSteps;

  /// Calo tiêu hao thực tế:
  /// - Bài tập bước chân (chạy/đi bộ): stepsDelta * 0.04 kcal/bước
  /// - Bài tập khác (đạp xe/kháng lực): Chỉ đốt calo khi có chuyển động (stepsDelta > 0)
  double get calories {
    if (isStepBased) {
      return stepsDelta * 0.04;
    } else {
      return stepsDelta * 0.1;
    }
  }

  /// Người dùng có đang di chuyển không (để hiển thị cảnh báo đứng yên)
  bool get isMoving => stepsDelta > 0;

  LiveWorkoutState copyWith({
    bool? isStepBased,
    int? activeSteps,
    bool? isPaused,
  }) {
    return LiveWorkoutState(
      isStepBased: isStepBased ?? this.isStepBased,
      activeSteps: activeSteps ?? this.activeSteps,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LiveWorkoutNotifier extends StateNotifier<LiveWorkoutState> {
  final Ref _ref;
  int _lastHealthSteps = 0;

  LiveWorkoutNotifier(this._ref) : super(const LiveWorkoutState());

  /// Gọi khi màn hình khởi tạo
  void init(String tenBaiTap) {
    _lastHealthSteps = _ref.read(healthProvider).steps;
    final isStepBased = _isStepBasedWorkout(tenBaiTap);

    state = LiveWorkoutState(
      isStepBased: isStepBased,
      activeSteps: 0,
      isPaused: false,
    );
  }

  void pause() {
    if (mounted) state = state.copyWith(isPaused: true);
  }

  void resume() {
    if (mounted) state = state.copyWith(isPaused: false);
  }

  /// Gọi mỗi khi pedometer cập nhật bước chân
  void updateSteps(int steps) {
    if (mounted) {
      final delta = steps - _lastHealthSteps;
      _lastHealthSteps = steps;
      
      if (!state.isPaused && delta > 0) {
        state = state.copyWith(activeSteps: state.activeSteps + delta);
      }
    }
  }

  void reset() {
    state = const LiveWorkoutState();
  }


  bool _isStepBasedWorkout(String name) {
    final lower = name.toLowerCase();
    return lower.contains('chạy') ||
        lower.contains('đi bộ') ||
        lower.contains('walk') ||
        lower.contains('run') ||
        lower.contains('morning run') ||
        lower.contains('bộ');
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final liveWorkoutProvider =
    StateNotifierProvider<LiveWorkoutNotifier, LiveWorkoutState>((ref) {
  final notifier = LiveWorkoutNotifier(ref);

  // Lắng nghe cập nhật bước chân từ healthProvider (real-time pedometer)
  ref.listen<int>(
    healthProvider.select((h) => h.steps),
    (_, newSteps) {
      notifier.updateSteps(newSteps);
    },
  );

  return notifier;
});
