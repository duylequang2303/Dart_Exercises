// lib/features/workout/data/models/activity_model.dart
import '../../domain/entities/activity_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel extends ActivityEntity {
  ActivityModel({
    required super.id,
    required super.title,
    required super.durationMinutes,
    required super.caloriesBurned,
    required super.date,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      title: data['title'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      caloriesBurned: data['caloriesBurned'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'date': Timestamp.fromDate(date),
    };
  }
}