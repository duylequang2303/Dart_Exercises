// lib/features/workout/presentation/services/workout_timer_service.dart
import 'dart:async';

class WorkoutTimerService {
  Timer? _timer;
  DateTime? _startTime;
  int _elapsedSecondsBeforePause = 0;
  bool _isRunning = false;

  void start(Function(int) onTick) {
    if (_isRunning) return;
    _isRunning = true;
    
    // Đánh dấu mốc thời gian thực tế dựa trên đồng hồ hệ thống
    _startTime = DateTime.now().subtract(Duration(seconds: _elapsedSecondsBeforePause));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final totalElapsed = DateTime.now().difference(_startTime!).inSeconds;
        onTick(totalElapsed);
      }
    });
  }

  int pause() {
    if (!_isRunning) return _elapsedSecondsBeforePause;
    _isRunning = false;
    _timer?.cancel();
    if (_startTime != null) {
      _elapsedSecondsBeforePause = DateTime.now().difference(_startTime!).inSeconds;
    }
    return _elapsedSecondsBeforePause;
  }

  void reset() {
    _timer?.cancel();
    _startTime = null;
    _elapsedSecondsBeforePause = 0;
    _isRunning = false;
  }

  int getActualSeconds() {
    if (!_isRunning || _startTime == null) return _elapsedSecondsBeforePause;
    return DateTime.now().difference(_startTime!).inSeconds;
  }
}