import 'dart:async';

/// Service responsible for timer/tick logic for workouts.
/// Extracted out of widgets so UI remains logic-free and placed in presentation layer.
class WorkoutTimerService {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  final StreamController<Duration> _controller = StreamController.broadcast();

  Timer? _countdownTimer;
  int? _countdownRemaining;
  final StreamController<int?> _countdownController = StreamController.broadcast();

  /// Broadcast stream of elapsed durations (emits every tick).
  Stream<Duration> get elapsedStream => _controller.stream;

  /// Broadcast stream of remaining countdown seconds. Emits int (seconds) while counting,
  /// and emits null when no countdown is active.
  Stream<int?> get countdownStream => _countdownController.stream;

  /// Start or resume the main workout timer.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      _controller.add(_elapsed);
    });
  }

  /// Stop (pause) the main timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Reset elapsed time to zero and emit update.
  void reset() {
    stop();
    _elapsed = Duration.zero;
    _controller.add(_elapsed);
  }

  /// Start a countdown (UI should display values from countdownStream).
  /// When countdown reaches 0 the main timer will automatically start.
  void startCountdown(int seconds) {
    _countdownTimer?.cancel();
    _countdownRemaining = seconds;
    _countdownController.add(_countdownRemaining);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdownRemaining == null) {
        t.cancel();
        return;
      }
      _countdownRemaining = _countdownRemaining! - 1;
      if (_countdownRemaining! >= 0) {
        _countdownController.add(_countdownRemaining);
      }
      if (_countdownRemaining! <= 0) {
        // End countdown
        t.cancel();
        _countdownRemaining = null;
        // Emit null to indicate no active countdown
        _countdownController.add(null);
        // Start main timer
        start();
      }
    });
  }

  /// Stop and clear countdown.
  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdownRemaining = null;
    _countdownController.add(null);
  }

  /// Get current elapsed without subscribing.
  Duration get elapsed => _elapsed;

  /// Dispose resources.
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _controller.close();
    _countdownController.close();
  }
}
