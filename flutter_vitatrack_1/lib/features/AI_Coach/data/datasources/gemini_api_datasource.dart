import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/user_health_context.dart';
import '../models/chat_message_model.dart';
import '../models/health_analysis_model.dart';
import '../models/coach_plan_model.dart';

/// Exception riêng cho lỗi Gemini API
class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;
  const GeminiApiException(this.message, {this.statusCode});

  @override
  String toString() => 'GeminiApiException: $message (status: $statusCode)';
}

class GeminiApiDataSource {
  final String _apiKey;
  final String _model;
  final Dio _dio;

  GeminiApiDataSource({
    required String apiKey,
    required String model,
    Dio? dio,
  })  : _apiKey = apiKey,
        _model = model,
        _dio = dio ?? Dio();

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
    // Gemini roles: user, model
    final contents = <Map<String, dynamic>>[];

    for (final msg in history) {
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.content}
        ]
      });
    }

    // Add current user message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ]
    });

    final systemInstruction = {
      'parts': [
        {'text': _buildSystemPrompt(context)}
      ]
    };

    final responseText = await _callGeminiApi(
      contents: contents,
      systemInstruction: systemInstruction,
      maxTokens: 1000,
    );

    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  // ─── Health Analysis ──────────────────────────────────────

  Future<HealthAnalysisModel> getHealthAnalysis(UserHealthContext context) async {
    final systemPrompt = '''
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
''';

    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': 'Phân tích dữ liệu sức khỏe hôm nay của tôi.'}
        ]
      }
    ];

    final systemInstruction = {
      'parts': [
        {'text': systemPrompt}
      ]
    };

    final responseText = await _callGeminiApi(
      contents: contents,
      systemInstruction: systemInstruction,
      maxTokens: 1000,
      jsonMode: true,
    );

    return _parseHealthAnalysis(responseText, context);
  }

  HealthAnalysisModel _parseHealthAnalysis(String responseText, UserHealthContext context) {
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
        waterRemaining: (context.dailyWaterGoalMl - context.waterIntakeMl) / 1000,
      );
    }
  }

  // ─── Coach Plan ───────────────────────────────────────────

  Future<CoachPlanModel> getCoachPlan(UserHealthContext context) async {
    final systemPrompt = '''
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
''';

    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': 'Tạo kế hoạch phù hợp với tình trạng của tôi.'}
        ]
      }
    ];

    final systemInstruction = {
      'parts': [
        {'text': systemPrompt}
      ]
    };

    final responseText = await _callGeminiApi(
      contents: contents,
      systemInstruction: systemInstruction,
      maxTokens: 1000,
      jsonMode: true,
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
          {'id': 'goal_1', 'title': 'Duy trì thói quen tốt', 'progressPercent': 50},
        ],
      });
    }
  }

  // ─── Food Image Analysis ──────────────────────────────────

  Future<Map<String, dynamic>> analyzeFoodImage(String base64Image) async {
    final contents = [
      {
        'parts': [
          {
            'inlineData': {
              'mimeType': 'image/jpeg',
              'data': base64Image,
            }
          },
          {
            'text': '''Tìm kiếm món ăn, đồ uống hoặc thực phẩm đóng gói (như chai nước, hộp sữa) trong ảnh, bỏ qua hậu cảnh.
Nếu trong ảnh HOÀN TOÀN KHÔNG CÓ đồ ăn/đồ uống (VD: chỉ có mặt người, phong cảnh, đồ vật thông thường), hãy trả về:
{
  "error": "Đây không phải là thức ăn hoặc đồ uống"
}
Nếu có đồ ăn, đồ uống hoặc chai lọ nước giải khát, trả về ĐÚNG định dạng JSON sau:
{
  "tenMonAn": "Tên món (VD: Nước Revive trắng, Cơm sườn)",
  "calo": 350,
  "protein": 15.0,
  "carbs": 40.0,
  "fat": 10.0
}
LƯU Ý QUAN TRỌNG: LUÔN CỐ GẮNG ước tính lượng calo lớn hơn 0 cho các loại đồ uống có đường, nước ngọt, thực phẩm đóng gói. Không trả về 0 trừ khi chắc chắn đó là nước lọc tinh khiết hoặc đồ uống zero calo. Ước tính dựa trên khẩu phần trong ảnh hoặc 1 khẩu phần tiêu chuẩn.'''
          }
        ]
      }
    ];

    try {
      final responseText = await _callGeminiApi(
        contents: contents,
        maxTokens: 500,
        jsonMode: true,
      );

      final jsonString = _extractJson(responseText);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        throw GeminiApiException(json['error']);
      }

      return {
        'tenMonAn': json['tenMonAn'] ?? 'Món ăn',
        'calo': (json['calo'] as num?)?.toInt() ?? 0,
        'protein': (json['protein'] as num?)?.toDouble() ?? 0.0,
        'carbs': (json['carbs'] as num?)?.toDouble() ?? 0.0,
        'fat': (json['fat'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      throw GeminiApiException('Lỗi phân tích ảnh với Gemini: ${e.toString()}');
    }
  }

  // ─── Core API call ────────────────────────────────────────

  Future<String> _callGeminiApi({
    required List<Map<String, dynamic>> contents,
    Map<String, dynamic>? systemInstruction,
    int maxTokens = 1000,
    bool jsonMode = false,
  }) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

    final requestData = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': maxTokens,
        if (jsonMode) 'responseMimeType': 'application/json',
      },
    };

    if (systemInstruction != null) {
      requestData['systemInstruction'] = systemInstruction;
    }

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: requestData,
      );

      if (response.statusCode != 200) {
        throw GeminiApiException(
          response.data['error']?['message'] ?? 'Lỗi không xác định từ Gemini',
          statusCode: response.statusCode,
        );
      }

      final candidates = response.data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw const GeminiApiException('Gemini trả về danh sách ứng viên trống');
      }

      final parts = candidates[0]['content']?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw const GeminiApiException('Gemini trả về content/parts trống');
      }

      final text = parts[0]['text'] as String?;
      if (text == null || text.isEmpty) {
        throw const GeminiApiException('Nội dung phản hồi từ Gemini bị rỗng');
      }

      return text;
    } on DioException catch (e) {
      throw GeminiApiException(
        e.response?.data['error']?['message'] ?? e.message ?? 'Lỗi kết nối Dio đến Gemini',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw GeminiApiException('Lỗi gọi Gemini API: ${e.toString()}');
    }
  }

  // ─── Helper ───────────────────────────────────────────────

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
