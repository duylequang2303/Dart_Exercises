import 'package:dio/dio.dart';
import 'package:flutter_vitatrack_1/core/services/firestore_service.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/workout_entity.dart';

class WorkoutRemoteDataSource {
  final Dio dio;
  final FirestoreService firestore;

  WorkoutRemoteDataSource({
    required this.dio,
    required this.firestore,
  });

  Future<void> saveWorkout(String uid, WorkoutEntity workout) async {
    await firestore.setDocument(
      'users/$uid/workouts',
      workout.id,
      {
        'id': workout.id,
        'name': workout.name,
        'durationMinutes': workout.duration.inMinutes,
        'date': DateTime.now().toIso8601String(),
        'exercises': workout.exercises.map((e) => {
          'id': e.id,
          'name': e.name,
          'sets': e.sets,
          'reps': e.reps,
          'durationSeconds': e.duration.inSeconds,
        }).toList(),
      },
    );
  }

  /// Tìm kiếm bài tập theo từ khóa và/hoặc nhóm cơ (muscleId)
  /// Trả về danh sách ActivityEntity
  Future<List<ActivityEntity>> searchExercises({
    String query = '',
    int? muscleId,
  }) async {
    try {
      final response = await dio.get(
        'https://wger.de/api/v2/exercise/',
        queryParameters: {
          'format': 'json',
          'language': '2',
          if (query.isNotEmpty) 'term': query,
          if (muscleId != null) 'muscles': muscleId.toString(),
          'limit': '50',
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) return [];
        
        final List<dynamic> results = data['results'] ?? [];

        return results.map((jsonItem) {
          final int id = jsonItem['id'] ?? 0;
          final String title = jsonItem['name'] ?? 'Không có tên';

          return ActivityEntity(
            id: id.toString(),
            title: title,
            durationMinutes: 30,      // Giá trị mặc định
            caloriesBurned: 150,      // Giá trị mặc định
            date: DateTime.now(),
          );
        }).toList();
      } else {
        throw HttpException(
          'Lỗi HTTP ${response.statusCode}: ${response.statusMessage ?? 'Không rõ lý do'}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Lỗi kết nối mạng: Timeout');
      }
      throw NetworkException('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      // Ghi log để debug
      debugPrint('Lỗi không xác định trong WorkoutRemoteDataSource: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }
}

// Các exception tùy chỉnh
class HttpException implements Exception {
  final String message;
  final int? statusCode;
  HttpException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
  @override
  String toString() => message;
}