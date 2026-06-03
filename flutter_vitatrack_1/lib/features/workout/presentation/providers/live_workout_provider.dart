import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/health/presentation/providers/health_provider.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class LiveWorkoutState {
  /// Loại bài tập có tính theo bước chân không (chạy/đi bộ)
  final bool isStepBased;

  /// Số bước chân lúc bắt đầu bài tập (snapshot từ pedometer)
  final int initialSteps;

  /// Số bước chân hiện tại từ pedometer
  final int currentSteps;

  /// Nhịp tim hiện tại (mô phỏng dao động nhỏ)
  final int heartRate;

  const LiveWorkoutState({
    this.isStepBased = false,
    this.initialSteps = 0,
    this.currentSteps = 0,
    this.heartRate = 72,
  });

  /// Số bước chân đã đi trong lúc tập
  int get stepsDelta => (currentSteps - initialSteps).clamp(0, 999999);

  /// Calo tiêu hao thực tế:
  /// - Bài tập bước chân (chạy/đi bộ): stepsDelta * 0.04 kcal/bước
  /// - Bài tập khác (đạp xe/kháng lực): Chỉ đốt calo khi có chuyển động (stepsDelta > 0)
  double get calories {
    if (isStepBased) {
      return stepsDelta * 0.04;
    } else {
      // Với đạp xe/kháng lực: ước tính 0.1 kcal/bước dao động cơ thể;
      // nếu hoàn toàn đứng yên (stepsDelta == 0) => 0 calo
      return stepsDelta * 0.1;
    }
  }

  /// Người dùng có đang di chuyển không (để hiển thị cảnh báo đứng yên)
  bool get isMoving => stepsDelta > 0;

  LiveWorkoutState copyWith({
    bool? isStepBased,
    int? initialSteps,
    int? currentSteps,
    int? heartRate,
  }) {
    return LiveWorkoutState(
      isStepBased: isStepBased ?? this.isStepBased,
      initialSteps: initialSteps ?? this.initialSteps,
      currentSteps: currentSteps ?? this.currentSteps,
      heartRate: heartRate ?? this.heartRate,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class LiveWorkoutNotifier extends StateNotifier<LiveWorkoutState> {
  final Ref _ref;
  Timer? _heartRateTimer;
  final Random _random = Random();

  LiveWorkoutNotifier(this._ref) : super(const LiveWorkoutState());

  /// Gọi khi màn hình khởi tạo - snapshot số bước hiện tại làm điểm xuất phát
  void init(String tenBaiTap) {
    final currentSteps = _ref.read(healthProvider).steps;
    final isStepBased = _isStepBasedWorkout(tenBaiTap);

    state = LiveWorkoutState(
      isStepBased: isStepBased,
      initialSteps: currentSteps,
      currentSteps: currentSteps,
      heartRate: isStepBased ? 100 : 72,
    );

    // Giả lập dao động nhịp tim (không fake hẳn như cũ, chỉ dao động ±10 bpm xung quanh ngưỡng tương ứng)
    final baseHr = isStepBased ? 130 : 90;
    _heartRateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        final newHr = baseHr + _random.nextInt(20) - 10;
        state = state.copyWith(heartRate: newHr);
      }
    });
  }

  /// Gọi mỗi khi pedometer cập nhật bước chân (đọc từ healthProvider)
  void updateSteps(int steps) {
    if (mounted) {
      state = state.copyWith(currentSteps: steps);
    }
  }

  void reset() {
    _heartRateTimer?.cancel();
    state = const LiveWorkoutState();
  }

  @override
  void dispose() {
    _heartRateTimer?.cancel();
    super.dispose();
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
