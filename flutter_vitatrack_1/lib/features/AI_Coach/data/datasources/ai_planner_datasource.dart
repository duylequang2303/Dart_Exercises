import 'dart:convert';
import 'package:dio/dio.dart';

class AiPlannerDataSource {
  final Dio _dio;

  AiPlannerDataSource() : _dio = Dio();

  Future<Map<String, dynamic>?> generateWorkoutPlan(String apiKey, {String? userFeedback}) async {
    if (apiKey.isEmpty) return null;
    
    String prompt = '''Tạo một giáo án tập luyện toàn thân tại nhà cho người mới bắt đầu (khoảng 15 phút, không dụng cụ).''';
    if (userFeedback != null && userFeedback.isNotEmpty) {
      prompt += '''\n\nNgười dùng có yêu cầu đặc biệt: "$userFeedback". Hãy điều chỉnh giáo án cho phù hợp với yêu cầu này (ví dụ: tránh bài tập nhảy nếu đau gối, tăng cường độ nếu muốn khó hơn...).''';
    }
    prompt += '''\n\nTrả về ĐÚNG định dạng JSON sau, tuyệt đối không thêm text hay markdown block:
{
  "standardName": "Tên giáo án",
  "type": "cardio",
  "exercises": [
    {
      "name": "Tên động tác",
      "instructions": "Mô tả ngắn gọn cách thực hiện động tác này (1-2 câu).",
      "duration": 30,
      "reps": 0,
      "sets": 3,
      "restSeconds": 15,
      "caloPerMin": 8.0,
      "met": 5.0,
      "type": "cardio"
    }
  ]
}''';

    try {
      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7,
        },
      );

      final text = response.data['choices'][0]['message']['content'] as String;
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1) return null;
      
      final jsonStr = text.substring(start, end + 1);
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> generateMealPlan(String apiKey, int targetCalo, {String? userFeedback}) async {
    if (apiKey.isEmpty) return null;
    
    String prompt = '''Bạn là một Chuyên gia Dinh dưỡng (Health Coach) xuất sắc. Nhiệm vụ của bạn là lên thực đơn 1 ngày thật THỰC TẾ, NGON MIỆNG và TỐT CHO SỨC KHỎE dựa trên ẩm thực Việt Nam.
- Tổng lượng calo mục tiêu là khoảng $targetCalo kcal (được phép du di ±10-20% nếu cần để thực đơn hợp lý, KHÔNG nhồi nhét món vặt vô nghĩa chỉ để ép đủ số).
- Số lượng bữa: Gọn gàng từ 2 đến 4 bữa (Sáng, Trưa, Tối, hoặc thêm 1 bữa phụ).
- Dinh dưỡng: Luôn cân đối đủ Đạm (Protein), Tinh bột (Carb) và Chất béo (Fat). Ưu tiên thực phẩm lành mạnh dù người dùng có yêu cầu đồ ăn rẻ.''';
    if (userFeedback != null && userFeedback.isNotEmpty) {
      prompt += '''\n\nNgười dùng có yêu cầu thêm: "$userFeedback". 
- LƯU Ý QUAN TRỌNG: Hãy khéo léo đáp ứng yêu cầu này một cách thông minh và linh hoạt. 
- Nếu người dùng bảo "nghèo" hoặc "không có tiền", đừng bắt họ ăn mì tôm độc hại (vì bạn là app sức khỏe!). Hãy tư vấn các món RẺ nhưng VẪN KHỎE (ví dụ: Đậu hũ sốt cà chua, trứng luộc, rau muống xào tỏi, cơm trắng).
- Đừng cứng nhắc! Hãy làm như một vị huấn luyện viên có tâm, điều chỉnh thực đơn sát với yêu cầu nhưng giữ vững nguyên tắc bảo vệ sức khỏe.''';
    }
    prompt += '''\n\nTrả về ĐÚNG định dạng JSON mảng các món ăn. KHÔNG thêm markdown. KHÔNG gộp chung, KHÔNG giải thích lôi thôi.
[
  {
    "tenMonAn": "Cơm trắng (1 chén) + Đậu hũ sốt cà chua",
    "calo": 400,
    "protein": 20.0,
    "carbs": 50.0,
    "fat": 12.0
  }
]''';

    try {
      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7,
        },
      );

      final text = response.data['choices'][0]['message']['content'] as String;
      final start = text.indexOf('[');
      final end = text.lastIndexOf(']');
      if (start == -1 || end == -1) return null;
      
      final jsonStr = text.substring(start, end + 1);
      final List<dynamic> parsed = jsonDecode(jsonStr);
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }
}
