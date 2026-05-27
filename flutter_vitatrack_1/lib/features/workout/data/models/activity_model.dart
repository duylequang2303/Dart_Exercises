// lib/features/workout/data/models/activity_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_entity.dart';

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required String id,
    required String name,
    required int durationInMinutes,
    required int caloriesBurned,
    required String category,
  }) : super(
          id: id,
          name: name,
          durationInMinutes: durationInMinutes,
          caloriesBurned: caloriesBurned,
          category: category,
        );

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      durationInMinutes: json['duration_min'] ?? 0,
      caloriesBurned: json['calories'] ?? 0,
      category: json['category'] ?? 'Tất cả',
    );
  }
}

class WorkoutModel extends WorkoutEntity {
  const WorkoutModel({
    required String id,
    required String exerciseId,
    required String exerciseName,
    required int actualDurationInSeconds,
    required int totalCaloriesBurned,
    required DateTime timestamp,
  }) : super(
          id: id,
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          actualDurationInSeconds: actualDurationInSeconds,
          totalCaloriesBurned: totalCaloriesBurned,
          timestamp: timestamp,
        );

  factory WorkoutModel.fromEntity(WorkoutEntity entity) {
    return WorkoutModel(
      id: entity.id,
      exerciseId: entity.exerciseId,
      exerciseName: entity.exerciseName,
      actualDurationInSeconds: entity.actualDurationInSeconds,
      totalCaloriesBurned: entity.totalCaloriesBurned,
      timestamp: entity.timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'actualDurationInSeconds': actualDurationInSeconds,
      'totalCaloriesBurned': totalCaloriesBurned,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}