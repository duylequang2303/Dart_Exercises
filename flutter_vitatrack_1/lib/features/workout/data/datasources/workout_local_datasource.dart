import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

class WorkoutLocalDataSource {
  SharedPreferences? _prefs;
  final List<WorkoutEntity> _storage = [];

  WorkoutLocalDataSource() {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadFromPrefs();
    } catch (e) {
      print('Lỗi khởi tạo SharedPreferences trong WorkoutLocalDataSource: $e');
    }
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;
    try {
      final list = _prefs!.getStringList('workouts_history') ?? [];
      _storage.clear();
      for (final jsonStr in list) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        
        final exercisesList = (map['exercises'] as List<dynamic>?)?.map((e) {
          final exerciseMap = e as Map<String, dynamic>;
          return ExerciseEntity(
            id: exerciseMap['id'] ?? '',
            name: exerciseMap['name'] ?? '',
            sets: exerciseMap['sets'] ?? 0,
            reps: exerciseMap['reps'] ?? 0,
            duration: Duration(milliseconds: exerciseMap['durationMs'] ?? 0),
            restSeconds: exerciseMap['restSeconds'] ?? 45,
          );
        }).toList() ?? const <ExerciseEntity>[];

        _storage.add(WorkoutEntity(
          id: map['id'] ?? '',
          name: map['name'] ?? '',
          duration: Duration(milliseconds: map['durationMs'] ?? 0),
          exercises: exercisesList,
          calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
          steps: (map['steps'] as num?)?.toInt() ?? 0,
          iconCodePoint: (map['iconCodePoint'] as num?)?.toInt() ?? 0,
          type: map['type'] ?? 'cardio',
        ));
      }
    } catch (e) {
      print('Lỗi load workout history: $e');
    }
  }

  Future<void> startWorkout() async {
    // Placeholder
  }

  Future<void> saveWorkout(WorkoutEntity workout) async {
    _storage.add(workout);
    if (_prefs == null) return;
    try {
      final list = _prefs!.getStringList('workouts_history') ?? [];
      final workoutJson = jsonEncode({
        'id': workout.id,
        'name': workout.name,
        'durationMs': workout.duration.inMilliseconds,
        'calories': workout.calories,
        'steps': workout.steps,
        'iconCodePoint': workout.iconCodePoint,
        'type': workout.type,
        'exercises': workout.exercises.map((e) => {
          'id': e.id,
          'name': e.name,
          'sets': e.sets,
          'reps': e.reps,
          'durationMs': e.duration.inMilliseconds,
          'restSeconds': e.restSeconds,
        }).toList(),
      });
      list.add(workoutJson);
      await _prefs!.setStringList('workouts_history', list);
    } catch (e) {
      print('Lỗi save workout: $e');
    }
  }

  Future<void> updateProgress(Duration elapsed) async {
    // Placeholder
  }

  Future<List<WorkoutEntity>> getAllWorkouts() async {
    if (_prefs == null) {
      await _init();
    }
    return List.unmodifiable(_storage);
  }
}
