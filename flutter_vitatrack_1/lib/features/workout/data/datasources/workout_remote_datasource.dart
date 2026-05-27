// lib/features/workout/data/datasources/workout_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class WorkoutRemoteDatasource {
  final Dio _dio;
  final FirebaseFirestore _firestore;

  WorkoutRemoteDatasource(this._dio, this._firestore);

  // Đổi tên hàm hoặc bổ sung chính xác tên hàm này để Provider gọi không bị lỗi
  Future<List<ExerciseModel>> searchExercises({
    required String query,
    String? muscleId, // Đổi thành String? category tùy thuộc cấu trúc app của bạn
  }) async {
    try {
      final response = await _dio.get('/exercises/search', queryParameters: {
        'q': query,
        'muscleId': muscleId,
      });
      if (response.statusCode == 200) {
        final List listData = response.data['data'] ?? [];
        return listData.map((e) => ExerciseModel.fromJson(e)).toList();
      }
      throw Exception("Lỗi cấu trúc dữ liệu mạng");
    } catch (e) {
      throw Exception("Không thể kết nối API Server: $e");
    }
  }

  Future<void> saveWorkoutToFirestore(String uid, WorkoutModel model) async {
    await _firestore.collection('users').doc(uid).collection('workouts').add(model.toFirestore());
  }
}