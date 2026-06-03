import 'dart:convert';
import 'package:dio/dio.dart';

class WorkoutAiService {
  final String _apiKey;
  final String _model;
  final Dio _dio;

  WorkoutAiService({
    required String apiKey,
    required String model,
    Dio? dio,
  })  : _apiKey = apiKey,
        _model = model,
        _dio = dio ?? Dio();

  Future<Map<String, dynamic>> parseWorkoutPlan(String userInput) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

    final prompt = '''
Bạn là chuyên gia thể hình và huấn luyện viên thể thao chuyên nghiệp.
Hãy phân tích yêu cầu bài tập của người dùng: "$userInput".

Phân loại và trả về chương trình tập luyện chi tiết dưới dạng JSON.
Nếu bài tập thuộc nhóm tập cơ/tạ/Gym (kháng lực như hít đất, squat, pull up, plank, tạ tay...), set "type" là "strength".
Nếu bài tập thuộc nhóm tim mạch/thể lực/chạy nhảy (chạy bộ, đạp xe, bơi lội, đi bộ...), set "type" là "cardio".

Trả về ĐÚNG định dạng JSON sau, không thêm bất kỳ văn bản giải thích nào khác:
{
  "type": "strength" hoặc "cardio",
  "standardName": "Tên chuẩn hóa tiếng Việt (ví dụ: Tập cơ ngực tại nhà, Chạy bộ buổi sáng)",
  "exercises": [
    {
      "name": "Tên bài tập con (ví dụ: Hít đất cơ bản)",
      "sets": 3,
      "reps": 12,
      "restSeconds": 45,
      "durationSeconds": 0
    }
  ]
}
Lưu ý:
- "durationSeconds": Số giây giữ thế cho các bài như Plank (nếu dùng reps thì để 0).
- Với nhóm "cardio", danh sách "exercises" có thể để trống hoặc thêm các chặng nhỏ nếu cần.
''';

    final requestData = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      },
    };

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: requestData,
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi gọi Gemini: Code ${response.statusCode}');
      }

      final candidates = response.data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Phản hồi trống từ Gemini');
      }

      final text = candidates[0]['content']?['parts']?[0]?['text'] as String?;
      if (text == null || text.isEmpty) {
        throw Exception('Nội dung phản hồi trống');
      }

      final jsonStr = _extractJson(text);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      return map;
    } catch (e) {
      print('Lỗi WorkoutAiService.parseWorkoutPlan: $e');
      // Trả về giáo án fallback an toàn nếu gặp sự cố API
      return _getFallbackPlan(userInput);
    }
  }

  Map<String, dynamic> _getFallbackPlan(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('chạy') || lower.contains('run') || lower.contains('bộ') || lower.contains('đi') || lower.contains('walk')) {
      return {
        'type': 'cardio',
        'standardName': input,
        'exercises': <Map<String, dynamic>>[],
      };
    }
    if (lower.contains('đạp') || lower.contains('bike') || lower.contains('cycling')) {
      return {
        'type': 'cardio',
        'standardName': 'Đạp xe thể lực',
        'exercises': <Map<String, dynamic>>[],
      };
    }
    if (lower.contains('bơi') || lower.contains('swim')) {
      return {
        'type': 'cardio',
        'standardName': 'Bơi lội tự do',
        'exercises': <Map<String, dynamic>>[],
      };
    }
    
    // Mặc định là strength bài tập tạ/gym
    return {
      'type': 'strength',
      'standardName': input.isNotEmpty ? input : 'Tập Gym / Sức mạnh',
      'exercises': [
        {'name': 'Hít đất (Push Ups)', 'sets': 3, 'reps': 12, 'restSeconds': 45, 'durationSeconds': 0},
        {'name': 'Squats (Gánh đùi)', 'sets': 3, 'reps': 15, 'restSeconds': 45, 'durationSeconds': 0},
        {'name': 'Plank', 'sets': 3, 'reps': 0, 'restSeconds': 45, 'durationSeconds': 45},
      ],
    };
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
