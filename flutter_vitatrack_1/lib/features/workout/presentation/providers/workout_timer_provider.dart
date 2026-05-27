// lib/features/workout/presentation/providers/workout_timer_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/workout_timer_service.dart';

// 1. Định nghĩa kiểu dữ liệu trạng thái (Fix lỗi 'TimerStateData isn't a type')
class TimerStateData {
  final int seconds;
  final bool isRunning;
  const TimerStateData({this.seconds = 0, this.isRunning = false});
}

// 2. Triển khai lớp Notifier để điều khiển State (Fix lỗi 'WorkoutTimerNotifier isn't a type')
class WorkoutTimerNotifier extends StateNotifier<TimerStateData> {
  final WorkoutTimerService _timerService;

  WorkoutTimerNotifier(this._timerService) : super(const TimerStateData());

  void startTracking() {
    state = TimerStateData(seconds: state.seconds, isRunning: true);
    _timerService.start((currentSeconds) {
      state = TimerStateData(seconds: currentSeconds, isRunning: true);
    });
  }

  void forceSyncFromBackground() {
    if (state.isRunning) {
      state = TimerStateData(seconds: _timerService.getActualSeconds(), isRunning: true);
    }
  }

  void pauseTracking() {
    final pausedSeconds = _timerService.pause();
    state = TimerStateData(seconds: pausedSeconds, isRunning: false);
  }

  void resetTracking() {
    _timerService.reset();
    state = const TimerStateData(seconds: 0, isRunning: false);
  }
}

// 3. Khai báo các biến Global Provider ở cấp độ file theo đúng kiến trúc của bạn
final timerServiceProvider = Provider((ref) => WorkoutTimerService());

final workoutTimerProvider = StateNotifierProvider<WorkoutTimerNotifier, TimerStateData>((ref) {
  return WorkoutTimerNotifier(ref.watch(timerServiceProvider));
});