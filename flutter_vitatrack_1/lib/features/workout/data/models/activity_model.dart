// lib/features/workout/data/models/activity_model.dart
import '../../domain/entities/activity_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel extends ActivityEntity {
  final String type;
  final List<dynamic> exercises;
  final int durationMs;
  final double calories;

  ActivityModel({
    required super.id,
    required String name,
    required this.durationMs,
    required this.calories,
    required super.date,
    this.type = 'cardio',
    this.exercises = const [],
  }) : super(
          title: name,
          durationMinutes: (durationMs / 60000).round(),
          caloriesBurned: calories.round(),
        );

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      name: data['name'] ?? data['title'] ?? '',
      durationMs: data['durationMs'] ?? (data['durationMinutes'] ?? 0) * 60000,
      calories: (data['calories'] ?? data['caloriesBurned'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'cardio',
      exercises: data['exercises'] ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': title,
      'durationMs': durationMs,
      'calories': calories,
      'type': type,
      'exercises': exercises,
      'date': Timestamp.fromDate(date),
    };
  }
}