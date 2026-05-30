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
  static const String _model = 'llama-3.3-70b-versatile';

  final String _apiKey;
  final Dio _dio;

  GroqApiDataSource({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ?? Dio();

  // ─── System Prompt cho Chat ───────────────────────────────

  String _buildSystemPrompt(UserHealthContext context) {
    return '''
Bạn là VitaTrack AI Coach - trợ lý sức khỏe thông minh, cá nhân hóa.

VAI TRÒ:
- Tư vấn sức khỏe, tập luyện, dinh dưỡng và giấc ngủ
- Phân tích dữ liệu và đưa ra lời khuyên PHÙ HỢP với thể trạng người dùng
- Động viên người dùng đạt mục tiêu sức khỏe

QUY TẮC:
- Luôn trả lời bằng tiếng Việt, thân thiện và ngắn gọn
- Dựa vào dữ liệu THỰC TẾ của người dùng để tư vấn
- Tính đến tuổi, giới tính, BMI khi đưa ra lời khuyên
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

    final responseText = await _callGroqApi(
      messages: messages,
      maxTokens: 500,
    );

    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // ─── Health Analysis ──────────────────────────────────────

  Future<HealthAnalysisModel> getHealthAnalysis(
      UserHealthContext context) async {
    final messages = [
      {
        'role': 'system',
        'content': '''
Bạn là VitaTrack AI Coach - chuyên gia sức khỏe cá nhân hóa.
Nhiệm vụ: Phân tích dữ liệu sức khỏe và trả về JSON CHÍNH XÁC.

QUY TẮC QUAN TRỌNG:
1. Chỉ đánh giá dựa trên dữ liệu THỰC TẾ được cung cấp
2. Tính đến thể trạng cá nhân (tuổi, giới tính, BMI, mục tiêu)
3. Hôm nay là ${_getTodayName()} - chỉ điền dữ liệu ngày đã qua, ngày chưa đến để 0
4. diemTot và canCaiThien phải CỤ THỂ, dựa trên số liệu thực
5. waterIntake và waterRemaining tính bằng LÍT (chia cho 1000)
6. caloriesGoalPercent là phần trăm đạt được so với mục tiêu

${context.toPromptContext()}

Trả về ĐÚNG JSON này, KHÔNG thêm text khác:
{
  "summary": "Nhận xét 2-3 câu cụ thể về phong độ hôm nay dựa trên dữ liệu thực tế",
  "diemTot": [
    "Điểm tốt cụ thể 1 kèm số liệu thực tế",
    "Điểm tốt cụ thể 2 kèm số liệu thực tế"
  ],
  "canCaiThien": [
    "Việc cần cải thiện 1 kèm gợi ý cụ thể",
    "Việc cần cải thiện 2 kèm gợi ý cụ thể"
  ],
  "bmiDanhGia": "Đánh giá BMI và ý nghĩa với sức khỏe của người dùng",
  "sleepQualityChange": 0,
  "waterIntake": 0.0,
  "waterRemaining": 0.0,
  "caloriesBurned": 0,
  "caloriesGoalPercent": 0,
  "weeklyActivity": {
    "T2": 0, "T3": 0, "T4": 0,
    "T5": 0, "T6": 0, "T7": 0, "CN": 0
  }
}
''',
      },
      {
        'role': 'user',
        'content': 'Phân tích sức khỏe hôm nay của tôi.',
      },
    ];

    final responseText = await _callGroqApi(
      messages: messages,
      maxTokens: 1000,
    );
    return _parseHealthAnalysis(responseText, context);
  }

  HealthAnalysisModel _parseHealthAnalysis(
      String responseText, UserHealthContext context) {
    try {
      final jsonString = _extractJson(responseText);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HealthAnalysisModel.fromJson(json);
    } catch (e) {
      return HealthAnalysisModel.fallback(
        summaryText: responseText.length > 200
            ? responseText.substring(0, 200)
            : responseText,
        caloriesBurned: context.caloriesBurned,
        waterIntake: context.waterIntakeMl / 1000,
        waterRemaining:
            (context.dailyWaterGoalMl - context.waterIntakeMl) / 1000,
      );
    }
  }

  // ─── Coach Plan ───────────────────────────────────────────

  Future<CoachPlanModel> getCoachPlan(UserHealthContext context) async {
    final messages = [
      {
        'role': 'system',
        'content': '''
Bạn là VitaTrack AI Coach. Tạo kế hoạch sức khỏe CÁ NHÂN HÓA và trả về JSON.

QUY TẮC:
- Dựa vào mục tiêu, cường độ tập và thể trạng để tạo kế hoạch PHÙ HỢP
- Task phải THỰC TẾ và KHẢ THI với người dùng
- progressPercent dựa trên dữ liệu thực tế hôm nay

${context.toPromptContext()}

Trả về ĐÚNG định dạng JSON sau, không thêm text nào khác:
{
  "dailyTasks": [
    {"id": "task_1", "title": "Task phù hợp với mục tiêu 1", "isCompleted": false},
    {"id": "task_2", "title": "Task phù hợp với mục tiêu 2", "isCompleted": false},
    {"id": "task_3", "title": "Task phù hợp với mục tiêu 3", "isCompleted": false},
    {"id": "task_4", "title": "Task phù hợp với mục tiêu 4", "isCompleted": false}
  ],
  "weeklyGoals": [
    {"id": "goal_1", "title": "Mục tiêu tuần phù hợp 1", "progressPercent": 0},
    {"id": "goal_2", "title": "Mục tiêu tuần phù hợp 2", "progressPercent": 0}
  ]
}
''',
      },
      {
        'role': 'user',
        'content': 'Tạo kế hoạch phù hợp với thể trạng và mục tiêu của tôi.',
      },
    ];

    final responseText = await _callGroqApi(
      messages: messages,
      maxTokens: 600,
    );
    return _parseCoachPlan(responseText);
  }

  CoachPlanModel _parseCoachPlan(String responseText) {
    try {
      final jsonString = _extractJson(responseText);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CoachPlanModel.fromJson(json);
    } catch (e) {
      return CoachPlanModel.fromJson({
        'dailyTasks': [
          {'id': 'task_1', 'title': 'Uống 2L nước', 'isCompleted': false},
          {'id': 'task_2', 'title': 'Đi bộ 10,000 bước', 'isCompleted': false},
          {'id': 'task_3', 'title': 'Tập thể dục 30 phút', 'isCompleted': false},
          {'id': 'task_4', 'title': 'Ngủ trước 23h', 'isCompleted': false},
        ],
        'weeklyGoals': [
          {
            'id': 'goal_1',
            'title': 'Duy trì thói quen tốt',
            'progressPercent': 50
          },
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
      if (choices.isEmpty) {
        throw const GroqApiException('Groq trả về kết quả rỗng');
      }

      final content = choices[0]['message']['content'] as String?;
      if (content == null || content.isEmpty) {
        throw const GroqApiException('Nội dung phản hồi bị rỗng');
      }

      return content;
    } on DioException catch (e) {
      throw GroqApiException(
        e.response?.data['error']?['message'] ??
            e.message ??
            'Lỗi kết nối Dio',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is GroqApiException) rethrow;
      throw GroqApiException('Lỗi không xác định: ${e.toString()}');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────

  /// Lấy tên ngày hôm nay bằng tiếng Việt
  String _getTodayName() {
    final weekday = DateTime.now().weekday;
    const days = {
      1: 'T2 (Thứ Hai)',
      2: 'T3 (Thứ Ba)',
      3: 'T4 (Thứ Tư)',
      4: 'T5 (Thứ Năm)',
      5: 'T6 (Thứ Sáu)',
      6: 'T7 (Thứ Bảy)',
      7: 'CN (Chủ Nhật)',
    };
    return days[weekday] ?? 'T2';
  }

  /// Trích xuất JSON thuần từ response
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