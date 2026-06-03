import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/user_health_context.dart';
import '../models/chat_message_model.dart';
import '../models/health_analysis_model.dart';
import '../models/coach_plan_model.dart';
import 'gemini_api_datasource.dart';

/// Exception riêng cho lỗi Groq API
class GroqApiException implements Exception {
  final String message;
  final int? statusCode;
  const GroqApiException(this.message, {this.statusCode});

  @override
  String toString() => 'GroqApiException: $message (status: $statusCode)';
}

/// Đây là nơi DUY NHẤT được phép gọi Groq API
class GroqApiDataSource {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'llama-3.3-70b-versatile';

  final String _apiKey;
  final Dio _dio;
  final GeminiApiDataSource? _geminiDataSource;

  GroqApiDataSource({
    required String apiKey,
    String? geminiApiKey,
    String? geminiModel,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio(),
        _geminiDataSource = (geminiApiKey != null && geminiApiKey.isNotEmpty)
            ? GeminiApiDataSource(
                apiKey: geminiApiKey,
                model: geminiModel ?? 'gemini-2.5-flash',
                dio: dio,
              )
            : null;

  // ─── System Prompt ────────────────────────────────────────

  String _buildSystemPrompt(UserHealthContext context) {
    return '''
Bạn là VitaTrack AI Coach - trợ lý sức khỏe thông minh.

VAI TRÒ:
- Tư vấn sức khỏe, tập luyện, dinh dưỡng và giấc ngủ
- Phân tích dữ liệu và đưa ra lời khuyên cá nhân hóa
- Động viên người dùng đạt mục tiêu sức khỏe

QUY TẮC:
- Luôn trả lời bằng tiếng Việt, thân thiện và ngắn gọn
- Dựa vào dữ liệu thực tế của người dùng để tư vấn
- Không chẩn đoán bệnh

${context.toPromptContext()}
''';
  }

  // ─── Chat ─────────────────────────────────────────────────

  Future<ChatMessageModel> sendChatMessage({
    required String userMessage,
    required List<ChatMessageModel> history,
    required UserHealthContext context,
  }) async {
    if (_geminiDataSource != null) {
      try {
        print('Using Gemini for chat message...');
        return await _geminiDataSource.sendChatMessage(
          userMessage: userMessage,
          history: history,
          context: context,
        );
      } catch (e) {
        print('Gemini chat failed, falling back to Groq: $e');
      }
    }

    final messages = [
      {'role': 'system', 'content': _buildSystemPrompt(context)},
      ...history.map((msg) => msg.toGroqMessage()),
      {'role': 'user', 'content': userMessage},
    ];

    final responseText = await _callGroqApi(messages: messages, maxTokens: 500);

    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // ─── Health Analysis ──────────────────────────────────────

  Future<HealthAnalysisModel> getHealthAnalysis(UserHealthContext context) async {
    if (_geminiDataSource != null) {
      try {
        print('Using Gemini for health analysis...');
        return await _geminiDataSource.getHealthAnalysis(context);
      } catch (e) {
        print('Gemini health analysis failed, falling back to Groq: $e');
      }
    }

    final messages = [
      {
        'role': 'system',
        'content': '''
Bạn là VitaTrack AI Coach. Phân tích dữ liệu sức khỏe và trả về JSON.

${context.toPromptContext()}

Trả về ĐÚNG định dạng JSON sau, không thêm text nào khác:
{
  "summary": "Nhận xét ngắn gọn 1-2 câu về phong độ tổng thể",
  "sleepQualityChange": 15,
  "waterIntake": 1.8,
  "waterRemaining": 0.7,
  "caloriesBurned": 450,
  "caloriesGoalPercent": 65,
  "weeklyActivity": {
    "T2": 80, "T3": 60, "T4": 90,
    "T5": 45, "T6": 70, "T7": 85, "CN": 30
  }
}
''',
      },
      {'role': 'user', 'content': 'Phân tích dữ liệu sức khỏe hôm nay của tôi.'},
    ];

    final responseText = await _callGroqApi(messages: messages, maxTokens: 800);
    return _parseHealthAnalysis(responseText, context);
  }

  HealthAnalysisModel _parseHealthAnalysis(String responseText, UserHealthContext context) {
    try {
      final jsonString = _extractJson(responseText);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HealthAnalysisModel.fromJson(json);
    } catch (e) {
      // Fallback nếu AI không trả đúng JSON
      return HealthAnalysisModel.fallback(
        summaryText: responseText.length > 200
            ? responseText.substring(0, 200)
            : responseText,
        caloriesBurned: context.caloriesBurned,
        waterIntake: context.waterIntakeMl / 1000,
        waterRemaining: (context.dailyWaterGoalMl - context.waterIntakeMl) / 1000,
      );
    }
  }

  // ─── Coach Plan ───────────────────────────────────────────

  Future<CoachPlanModel> getCoachPlan(UserHealthContext context) async {
    if (_geminiDataSource != null) {
      try {
        print('Using Gemini for coach plan...');
        return await _geminiDataSource.getCoachPlan(context);
      } catch (e) {
        print('Gemini coach plan failed, falling back to Groq: $e');
      }
    }

    final messages = [
      {
        'role': 'system',
        'content': '''
Bạn là VitaTrack AI Coach. Tạo kế hoạch sức khỏe và trả về JSON.

${context.toPromptContext()}

Trả về ĐÚNG định dạng JSON sau, không thêm text nào khác:
{
  "dailyTasks": [
    {"id": "task_1", "title": "Uống 2L nước", "isCompleted": false},
    {"id": "task_2", "title": "Đi bộ 10,000 bước", "isCompleted": false},
    {"id": "task_3", "title": "Tập yoga 20 phút", "isCompleted": false},
    {"id": "task_4", "title": "Ngủ trước 23h", "isCompleted": false}
  ],
  "weeklyGoals": [
    {"id": "goal_1", "title": "Giảm 0.5kg", "progressPercent": 60},
    {"id": "goal_2", "title": "Tập 5 ngày/tuần", "progressPercent": 80}
  ]
}
''',
      },
      {'role': 'user', 'content': 'Tạo kế hoạch phù hợp với tình trạng của tôi.'},
    ];

    final responseText = await _callGroqApi(messages: messages, maxTokens: 600);
    return _parseCoachPlan(responseText);
  }

  CoachPlanModel _parseCoachPlan(String responseText) {
    try {
      final jsonString = _extractJson(responseText);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CoachPlanModel.fromJson(json);
    } catch (e) {
      // Fallback kế hoạch mặc định nếu parse thất bại
      return CoachPlanModel.fromJson({
        'dailyTasks': [
          {'id': 'task_1', 'title': 'Uống 2L nước', 'isCompleted': false},
          {'id': 'task_2', 'title': 'Đi bộ 10,000 bước', 'isCompleted': false},
          {'id': 'task_3', 'title': 'Tập thể dục 30 phút', 'isCompleted': false},
          {'id': 'task_4', 'title': 'Ngủ trước 23h', 'isCompleted': false},
        ],
        'weeklyGoals': [
          {'id': 'goal_1', 'title': 'Duy trì thói quen tốt', 'progressPercent': 50},
        ],
      });
    }
  }

  // ─── Food Image Analysis ──────────────────────────────────

  Future<Map<String, dynamic>> analyzeFoodImage(String base64Image) async {
    if (_geminiDataSource != null) {
      try {
        print('Using Gemini for food image analysis...');
        return await _geminiDataSource.analyzeFoodImage(base64Image);
      } catch (e) {
        print('Gemini food image analysis failed, falling back to Groq: $e');
      }
    }

    const visionModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

    final messages = [
      {
        'role': 'user',
        'content': [
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,$base64Image',
            },
          },
          {
            'type': 'text',
            'text': '''Phân tích món ăn trong ảnh và trả về JSON.
Trả về ĐÚNG định dạng JSON sau, không thêm text nào khác:
{
  "tenMonAn": "Tên món ăn",
  "calo": 350,
  "protein": 15.0,
  "carbs": 40.0,
  "fat": 10.0
}
Ước tính cho 1 khẩu phần thông thường (gram). Nếu không nhận ra món ăn, vẫn ước tính dựa trên những gì thấy trong ảnh.''',
          },
        ],
      },
    ];

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
          'model': visionModel,
          'messages': messages,
          'max_tokens': 300,
          'temperature': 0.3,
        },
      );

      if (response.statusCode != 200) {
        throw GroqApiException(
          response.data['error']?['message'] ?? 'Lỗi phân tích ảnh',
          statusCode: response.statusCode,
        );
      }

      final choices = response.data['choices'] as List<dynamic>;
      if (choices.isEmpty) throw const GroqApiException('Không có kết quả phân tích');

      final content = choices[0]['message']['content'] as String? ?? '';
      final jsonString = _extractJson(content);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return {
        'tenMonAn': json['tenMonAn'] ?? 'Món ăn',
        'calo': (json['calo'] as num?)?.toInt() ?? 0,
        'protein': (json['protein'] as num?)?.toDouble() ?? 0.0,
        'carbs': (json['carbs'] as num?)?.toDouble() ?? 0.0,
        'fat': (json['fat'] as num?)?.toDouble() ?? 0.0,
      };
    } on DioException catch (e) {
      throw GroqApiException(
        e.response?.data['error']?['message'] ?? e.message ?? 'Lỗi kết nối',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw GroqApiException('Lỗi phân tích ảnh: ${e.toString()}');
    }
  }

  // ─── Core API call ────────────────────────────────────────

  Future<String> _callGroqApi({
    required List<Map<String, dynamic>> messages,
    int maxTokens = 500,
  }) async {
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
          'messages': messages,
          'max_tokens': maxTokens,
          'temperature': 0.7,
        },
      );

      if (response.statusCode != 200) {
        throw GroqApiException(
          response.data['error']?['message'] ?? 'Lỗi không xác định',
          statusCode: response.statusCode,
        );
      }

      final choices = response.data['choices'] as List<dynamic>;

      if (choices.isEmpty) throw const GroqApiException('Groq trả về kết quả rỗng');

      final content = choices[0]['message']['content'] as String?;
      if (content == null || content.isEmpty) {
        throw const GroqApiException('Nội dung phản hồi bị rỗng');
      }

      return content;
    } on DioException catch (e) {
      throw GroqApiException(
        e.response?.data['error']?['message'] ?? e.message ?? 'Lỗi kết nối Dio',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw GroqApiException('Lỗi không xác định: ${e.toString()}');
    }
  }

  // ─── Helper ───────────────────────────────────────────────

  /// Trích xuất JSON thuần từ response
  /// AI đôi khi bọc JSON trong ```json ... ```
  String _extractJson(String text) {
    final jsonBlockRegex = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonBlockRegex.firstMatch(text);
    if (match != null) return match.group(1)!.trim();

    final codeBlockRegex = RegExp(r'```\s*([\s\S]*?)\s*```');
    final codeMatch = codeBlockRegex.firstMatch(text);
    if (codeMatch != null) return codeMatch.group(1)!.trim();

    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return text.substring(jsonStart, jsonEnd + 1);
    }

    return text.trim();
  }
}