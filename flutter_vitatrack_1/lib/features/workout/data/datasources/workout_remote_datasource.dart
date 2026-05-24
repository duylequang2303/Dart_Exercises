import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/activity_entity.dart';

class WorkoutRemoteDataSource {
  final http.Client client;

  WorkoutRemoteDataSource({required this.client});

  /// Tìm kiếm bài tập theo từ khóa và/hoặc nhóm cơ (muscleId)
  /// Trả về danh sách ActivityEntity
  Future<List<ActivityEntity>> searchExercises({
    String query = '',
    int? muscleId,
  }) async {
    try {
      final Uri uri = Uri.https(
        'wger.de',
        '/api/v2/exercise/',
        {
          'format': 'json',
          'language': '2',
          if (query.isNotEmpty) 'term': query,
          if (muscleId != null) 'muscles': muscleId.toString(),
          'limit': '50',
        },
      );

      final response = await client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        if (responseBody.isEmpty) {
          return [];
        }
        final Map<String, dynamic> data = json.decode(responseBody);
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
          'Lỗi HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Không rõ lý do'}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Lỗi kết nối mạng: ${e.message}');
    } on FormatException catch (e) {
      throw DataParsingException('Dữ liệu trả về không đúng định dạng JSON: $e');
    } catch (e) {
      // Ghi log để debug
      print('Lỗi không xác định trong WorkoutRemoteDataSource: $e');
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