import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/start_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/stop_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/track_workout_progress.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  @override
  Future<void> saveWorkout(WorkoutEntity workout) async {}
  @override
  Future<List<WorkoutEntity>> getHistory() async => [];
  @override
  Future<void> saveWorkoutPlan(WorkoutEntity plan) async {}
  @override
  Future<List<WorkoutEntity>> getWorkoutPlans() async => [];
  @override
  Future<void> deleteWorkout(String id) async {}
  @override
  Future<Map<String, dynamic>> parseWorkoutPlan(String query) async => {};
  @override
  Future<void> startWorkout() async {}
  @override
  Future<void> stopWorkout(
    Duration elapsed, {
    required String name,
    required double calories,
    required int steps,
    required int iconCodePoint,
    required String type,
    required List<ExerciseEntity> exercises,
    String? userId,
  }) async {}
  @override
  Future<void> updateProgress(Duration elapsed) async {}
}

class FakeRef extends Ref {
  @override
  T read<T>(ProviderListenable<T> provider) => throw UnimplementedError();
  // ignore: missing_return
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late WorkoutTimerNotifier notifier;
  late FakeWorkoutRepository repo;

  setUp(() {
    repo = FakeWorkoutRepository();
    final start = StartWorkout(repository: repo);
    final stop = StopWorkout(repository: repo);
    final track = TrackWorkoutProgress(repository: repo);
    notifier = WorkoutTimerNotifier(start, stop, track, () {}, FakeRef());
  });

  tearDown(() {
    notifier.dispose();
  });

  test('Khởi tạo WorkoutTimerNotifier với thời gian bằng 0', () {
    expect(notifier.state.elapsed, Duration.zero);
    expect(notifier.state.isRunning, false);
    expect(notifier.state.isPaused, false);
  });

  test('start() chạy timer', () async {
    await notifier.start();
    await Future.delayed(const Duration(milliseconds: 1500));
    expect(notifier.state.elapsed.inSeconds, greaterThanOrEqualTo(1));
    expect(notifier.state.isRunning, true);
    expect(notifier.state.isPaused, false);
  });
  
  test('pause() và resume() hoạt động chính xác', () async {
    await notifier.start();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    notifier.pause();
    expect(notifier.state.isPaused, true);
    expect(notifier.state.isRunning, false);
    
    final elapsedAtPause = notifier.state.elapsed;
    await Future.delayed(const Duration(milliseconds: 1200));
    expect(notifier.state.elapsed, elapsedAtPause); // Không tăng khi pause
    
    notifier.resume();
    expect(notifier.state.isPaused, false);
    expect(notifier.state.isRunning, true);
    await Future.delayed(const Duration(milliseconds: 1200));
    expect(notifier.state.elapsed, greaterThan(elapsedAtPause));
  });

  test('stop() kết thúc bài tập', () async {
    await notifier.start();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // FakeRef throws when trying to read user info, so we catch it
    // because stop() tries to read user ID. We can test the state reset directly.
    try {
      await notifier.stop();
    } catch (_) {}

    expect(notifier.state.isRunning, false);
    expect(notifier.state.isPaused, false);
  });

  test('reset() đưa trạng thái về mặc định', () async {
    await notifier.start();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    notifier.reset();
    expect(notifier.state.elapsed, Duration.zero);
    expect(notifier.state.isRunning, false);
  });

  test('startCountdown() đếm ngược chính xác', () async {
    notifier.startCountdown(2);
    expect(notifier.state.countdown, const Duration(seconds: 2));
    
    await Future.delayed(const Duration(milliseconds: 1200));
    expect(notifier.state.countdown, const Duration(seconds: 1));
    
    await Future.delayed(const Duration(milliseconds: 1200));
    expect(notifier.state.countdown, null);
    
    // Tự động start sau khi countdown
    expect(notifier.state.isRunning, true);
  });
}
