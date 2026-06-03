import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/services/workout_timer_service.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/start_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/stop_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/track_workout_progress.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/data/services/workout_ai_service.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';

final workoutLocalDataSourceProvider = Provider<WorkoutLocalDataSource>((ref) => WorkoutLocalDataSource());

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) => WorkoutRepositoryImpl(localDataSource: ref.read(workoutLocalDataSourceProvider)));

final workoutHistoryProvider = FutureProvider<List<WorkoutEntity>>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  return await repo.getHistory();
});

final workoutAiServiceProvider = Provider<WorkoutAiService>((ref) {
  return WorkoutAiService(
    apiKey: kGeminiApiKey,
    model: kGeminiModel,
  );
});

final workoutTimerServiceProvider = Provider<WorkoutTimerService>((ref) {
  final s = WorkoutTimerService();
  ref.onDispose(() => s.dispose());
  return s;
});

final startWorkoutUseCaseProvider = Provider<StartWorkout>((ref) => StartWorkout(repository: ref.read(workoutRepositoryProvider)));

final stopWorkoutUseCaseProvider = Provider<StopWorkout>((ref) => StopWorkout(repository: ref.read(workoutRepositoryProvider)));

final trackWorkoutProgressUseCaseProvider = Provider<TrackWorkoutProgress>((ref) => TrackWorkoutProgress(repository: ref.read(workoutRepositoryProvider)));

final workoutElapsedProvider = StateNotifierProvider<WorkoutTimerNotifier, Duration>((ref) {
  final timer = ref.read(workoutTimerServiceProvider);
  final startUc = ref.read(startWorkoutUseCaseProvider);
  final stopUc = ref.read(stopWorkoutUseCaseProvider);
  final trackUc = ref.read(trackWorkoutProgressUseCaseProvider);
  return WorkoutTimerNotifier(timer, startUc, stopUc, trackUc, () {
    ref.invalidate(workoutHistoryProvider);
  });
});

final workoutCountdownProvider = StreamProvider<int?>((ref) {
  final s = ref.watch(workoutTimerServiceProvider);
  return s.countdownStream;
});

class WorkoutTimerNotifier extends StateNotifier<Duration> {
  final WorkoutTimerService _service;
  final StartWorkout _start;
  final StopWorkout _stop;
  final TrackWorkoutProgress _track;
  final void Function() _onStop;
  StreamSubscription<Duration>? _sub;

  WorkoutTimerNotifier(this._service, this._start, this._stop, this._track, this._onStop) : super(Duration.zero) {
    _sub = _service.elapsedStream.listen((d) {
      state = d;
      // fire-and-forget tracking
      _track.execute(d);
    });
  }

  Future<void> start() async {
    await _start.execute();
    _service.start();
  }

  Future<void> stop({
    String name = 'Bài tập',
    double calories = 0.0,
    int steps = 0,
    int iconCodePoint = 0,
    String type = 'cardio',
    List<ExerciseEntity> exercises = const [],
  }) async {
    _service.stop();
    await _stop.execute(
      state,
      name: name,
      calories: calories,
      steps: steps,
      iconCodePoint: iconCodePoint,
      type: type,
      exercises: exercises,
    );
    _onStop();
  }

  void reset() => _service.reset();

  void startCountdown(int seconds) => _service.startCountdown(seconds);

  void stopCountdown() => _service.stopCountdown();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
