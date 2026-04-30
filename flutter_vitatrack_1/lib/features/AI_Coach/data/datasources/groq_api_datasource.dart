
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/user_health_context.dart';
import '../models/chat_message_model.dart';
import '../models/health_analysis_model.dart';
import '../models/coach_plan_model.dart';

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
  static const String _model = 'llama3-70b-8192';

  final String _apiKey;
  final Dio _dio;

  GroqApiDataSource({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio();

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