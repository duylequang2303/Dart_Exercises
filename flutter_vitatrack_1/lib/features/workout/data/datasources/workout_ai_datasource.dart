import 'dart:convert';
import 'package:dio/dio.dart';

class WorkoutAiDataSource {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'llama-3.3-70b-versatile';

  final String _apiKey;
  final Dio _dio;

  WorkoutAiDataSource({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio();

  Future<Map<String, dynamic>> parseWorkoutPlan(String userInput) async {
    final prompt = '''
Bạn là chuyên gia thể hình và huấn luyện viên thể thao chuyên nghiệp.
Hãy phân tích yêu cầu bài tập của người dùng: "$userInput".

QUAN TRỌNG: Nếu yêu cầu KHÔNG PHẢI là bài tập thể dục/thể thao (ví dụ: tên trò chơi, món ăn, từ vô nghĩa, câu hỏi không liên quan...), hãy trả về:
{"type": "invalid", "standardName": "", "exercises": []}

Nếu là bài tập hợp lệ:
- Nhóm tập cơ/tạ/Gym (hít đất, squat, pull up, plank, tạ tay...) → set "type" là "strength"
- Nhóm tim mạch/thể lực (chạy bộ, đạp xe, bơi lội, đi bộ...) → set "type" là "cardio"

Trả về ĐÚNG định dạng JSON sau, không thêm bất kỳ văn bản giải thích nào khác:
{
  "type": "strength hoặc cardio hoặc invalid",
  "standardName": "Tên chuẩn hóa tiếng Việt",
  "exercises": [
    {
      "name": "Tên bài tập con",
      "sets": 3,
      "reps": 12,
      "restSeconds": 45,
      "durationSeconds": 0
    }
  ]
}
''';

    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        data: {
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.2,
          'max_tokens': 1000,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi gọi Groq: Code ${response.statusCode}');
      }

      final choices = response.data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw Exception('Phản hồi trống từ Groq');
      }

      final text = choices[0]['message']?['content'] as String?;
      if (text == null || text.isEmpty) {
        throw Exception('Nội dung phản hồi trống');
      }

      final jsonStr = _extractJson(text);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (map['type'] == 'invalid') {
        throw Exception('Yêu cầu không hợp lệ. Vui lòng nhập tên bài tập thể dục (ví dụ: hít đất, chạy bộ, squat...)');
      }

      return map;
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message'] ?? e.message ?? 'Lỗi kết nối';
      print('Lỗi WorkoutAiDataSource (Groq): $msg');
      throw Exception('Không thể tạo giáo án: $msg');
    } catch (e) {
      print('Lỗi WorkoutAiDataSource.parseWorkoutPlan: $e');
      throw Exception('Không thể tạo giáo án: $e');
    }
  }

  String _extractJson(String text) {
    final jsonBlockRegex = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonBlockRegex.firstMatch(text);
    if (match != null) return match.group(1)!.trim();

    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return text.substring(jsonStart, jsonEnd + 1);
    }

    return text.trim();
  }
}
