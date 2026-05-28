import 'dart:async';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/search_exercises.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/services/workout_timer_service.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/start_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/stop_workout.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/usecases/track_workout_progress.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_local_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/datasources/workout_remote_datasource.dart';
import 'package:flutter_vitatrack_1/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:flutter_vitatrack_1/core/services/firestore_service.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final workoutLocalDataSourceProvider = Provider<WorkoutLocalDataSource>((ref) => WorkoutLocalDataSource());

final workoutRemoteDataSourceProvider = Provider<WorkoutRemoteDataSource>((ref) {
  return WorkoutRemoteDataSource(
    dio: ref.read(dioProvider),
    firestore: ref.read(firestoreServiceProvider),
  );
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) => WorkoutRepositoryImpl(
  localDataSource: ref.read(workoutLocalDataSourceProvider),
  remoteDataSource: ref.read(workoutRemoteDataSourceProvider),
));

final workoutTimerServiceProvider = Provider<WorkoutTimerService>((ref) {
  final s = WorkoutTimerService();
  ref.onDispose(() => s.dispose());
  return s;
});

final startWorkoutUseCaseProvider = Provider<StartWorkout>((ref) => StartWorkout(repository: ref.read(workoutRepositoryProvider)));

final searchExercisesUseCaseProvider = Provider<SearchExercises>((ref) => SearchExercises(repository: ref.read(workoutRepositoryProvider)));

final stopWorkoutUseCaseProvider = Provider<StopWorkout>((ref) => StopWorkout(repository: ref.read(workoutRepositoryProvider)));

final trackWorkoutProgressUseCaseProvider = Provider<TrackWorkoutProgress>((ref) => TrackWorkoutProgress(repository: ref.read(workoutRepositoryProvider)));

final workoutElapsedProvider = StateNotifierProvider<WorkoutTimerNotifier, Duration>((ref) {
  final timer = ref.read(workoutTimerServiceProvider);
  final startUc = ref.read(startWorkoutUseCaseProvider);
  final stopUc = ref.read(stopWorkoutUseCaseProvider);
  final trackUc = ref.read(trackWorkoutProgressUseCaseProvider);
  final uid = ref.watch(nguoiDungHienTaiProvider)?.uid;
  return WorkoutTimerNotifier(timer, startUc, stopUc, trackUc, uid);
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
  final String? _uid;
  StreamSubscription<Duration>? _sub;

  WorkoutTimerNotifier(this._service, this._start, this._stop, this._track, this._uid) : super(Duration.zero) {
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

  Future<void> stop() async {
    _service.stop();
    if (_uid != null) {
      await _stop.execute(_uid, state);
    }
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
