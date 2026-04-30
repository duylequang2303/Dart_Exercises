// lib/features/workout/data/datasources/workout_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class WorkoutRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncWorkout(String userId, ActivityModel activity) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .add(activity.toFirestore());
  }
}