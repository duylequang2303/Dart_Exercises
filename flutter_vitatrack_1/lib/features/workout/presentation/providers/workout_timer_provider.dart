import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/start_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/stop_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/track_workout_progress.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/parse_workout_plan_usecase.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_remote_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_ai_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';

final workoutLocalDataSourceProvider = Provider<WorkoutLocalDataSource>((ref) => WorkoutLocalDataSource());

final workoutAiDataSourceProvider = Provider<WorkoutAiDataSource>((ref) {
  return WorkoutAiDataSource(apiKey: kGroqApiKey);
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final remoteDs = WorkoutRemoteDataSource();
  return WorkoutRepositoryImpl(
    localDataSource: ref.read(workoutLocalDataSourceProvider),
    remoteDataSource: remoteDs,
    aiDataSource: ref.read(workoutAiDataSourceProvider),
  );
});

final workoutHistoryProvider = FutureProvider<List<WorkoutEntity>>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  return await repo.getHistory();
});

final workoutPlansProvider = FutureProvider<List<WorkoutEntity>>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  return await repo.getWorkoutPlans();
});

final parseWorkoutPlanUseCaseProvider = Provider<ParseWorkoutPlanUseCase>((ref) {
  return ParseWorkoutPlanUseCase(ref.read(workoutRepositoryProvider));
});

final startWorkoutUseCaseProvider = Provider<StartWorkout>((ref) => StartWorkout(repository: ref.read(workoutRepositoryProvider)));

final stopWorkoutUseCaseProvider = Provider<StopWorkout>((ref) => StopWorkout(repository: ref.read(workoutRepositoryProvider)));

final trackWorkoutProgressUseCaseProvider = Provider<TrackWorkoutProgress>((ref) => TrackWorkoutProgress(repository: ref.read(workoutRepositoryProvider)));

class WorkoutTimerState {
  final Duration elapsed;
  final Duration? countdown;
  final bool isRunning;
  final bool isPaused;

  const WorkoutTimerState({
    this.elapsed = Duration.zero,
    this.countdown,
    this.isRunning = false,
    this.isPaused = false,
  });

  WorkoutTimerState copyWith({
    Duration? elapsed,
    Duration? countdown,
    bool clearCountdown = false,
    bool? isRunning,
    bool? isPaused,
  }) {
    return WorkoutTimerState(
      elapsed: elapsed ?? this.elapsed,
      countdown: clearCountdown ? null : (countdown ?? this.countdown),
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is WorkoutTimerState &&
      other.elapsed == elapsed &&
      other.countdown == countdown &&
      other.isRunning == isRunning &&
      other.isPaused == isPaused;
  }

  @override
  int get hashCode {
    return elapsed.hashCode ^
      countdown.hashCode ^
      isRunning.hashCode ^
      isPaused.hashCode;
  }
}

final workoutTimerNotifierProvider = StateNotifierProvider<WorkoutTimerNotifier, WorkoutTimerState>((ref) {
  final startUc = ref.read(startWorkoutUseCaseProvider);
  final stopUc = ref.read(stopWorkoutUseCaseProvider);
  final trackUc = ref.read(trackWorkoutProgressUseCaseProvider);
  return WorkoutTimerNotifier(startUc, stopUc, trackUc, () {
    ref.invalidate(workoutHistoryProvider);
  }, ref);
});

final workoutElapsedProvider = Provider<Duration>((ref) {
  return ref.watch(workoutTimerNotifierProvider).elapsed;
});

final workoutCountdownProvider = Provider<Duration?>((ref) {
  return ref.watch(workoutTimerNotifierProvider).countdown;
});

class WorkoutTimerNotifier extends StateNotifier<WorkoutTimerState> {
  final StartWorkout _start;
  final StopWorkout _stop;
  final TrackWorkoutProgress _track;
  final void Function() _onStop;
  final Ref _ref;
  
  Timer? _timer;
  Timer? _countdownTimer;

  WorkoutTimerNotifier(this._start, this._stop, this._track, this._onStop, this._ref) 
      : super(const WorkoutTimerState());

  Future<void> start() async {
    await _start.execute();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: true, isPaused: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newElapsed = state.elapsed + const Duration(seconds: 1);
      state = state.copyWith(elapsed: newElapsed);
      _track.execute(newElapsed);
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isPaused: true, isRunning: false);
  }

  void resume() {
    if (state.isPaused) {
      _startTimer();
    }
  }

  Future<void> stop({
    String name = 'Bài tập',
    double calories = 0.0,
    int steps = 0,
    int iconCodePoint = 0,
    String type = 'cardio',
    List<ExerciseEntity> exercises = const [],
    Duration? overrideDuration,
  }) async {
    _timer?.cancel();
    _timer = null;
    
    try {
      final userProvider = _ref.read(nguoiDungHienTaiProvider);
      final userId = userProvider?.uid;

      await _stop.execute(
        overrideDuration ?? state.elapsed,
        name: name,
        calories: calories,
        steps: steps,
        iconCodePoint: iconCodePoint,
        type: type,
        exercises: exercises,
        userId: userId,
      );
    } catch (e) {
      // Ignore if not in context
    } finally {
      _onStop();
      state = state.copyWith(isRunning: false, isPaused: false);
    }
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    state = const WorkoutTimerState();
  }

  void startCountdown(int seconds) {
    _countdownTimer?.cancel();
    state = state.copyWith(countdown: Duration(seconds: seconds));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.countdown == null) {
        t.cancel();
        return;
      }
      final remaining = state.countdown!.inSeconds - 1;
      
      if (remaining > 0) {
        state = state.copyWith(countdown: Duration(seconds: remaining));
      } else {
        t.cancel();
        state = state.copyWith(clearCountdown: true);
        _startTimer();
      }
    });
  }

  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    state = state.copyWith(clearCountdown: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
