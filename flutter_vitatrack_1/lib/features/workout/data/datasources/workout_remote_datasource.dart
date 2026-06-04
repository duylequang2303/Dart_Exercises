// lib/features/workout/data/datasources/workout_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class WorkoutRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncWorkout(String userId, ActivityModel activity) async {
    // DUPLICATE PREVENTION STRATEGY:
    // Instead of using .add() which generates a random Firestore ID and causes 
    // duplicates on retries/reconnects, we use .doc(activity.id).set() with SetOptions(merge: true).
    // The activity.id is deterministically generated (millisecondsSinceEpoch) when the workout stops.
    // This makes the synchronization idempotent: retrying the same workout sync
    // will just overwrite/merge the same document instead of creating duplicates.
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .doc(activity.id)
        .set(activity.toFirestore(), SetOptions(merge: true));
  }
}