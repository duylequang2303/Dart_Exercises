import '../entities/chat_message.dart';
import '../entities/user_health_context.dart';
import '../repositories/ai_coach_repository.dart';

class SendChatMessageUseCase {
  final AiCoachRepository _repository;
  const SendChatMessageUseCase(this._repository);

  Future<ChatMessage> execute({
    required String message,
    required UserHealthContext context,
    required List<ChatMessage> history,
  }) async {
    if (message.trim().isEmpty) {
      throw ArgumentError('Tin nhắn không được để trống');
    }

    // Giới hạn lịch sử gửi lên tối đa 10 tin để tránh vượt token
    final recentHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    return _repository.sendMessage(
      message: message.trim(),
      context: context,
      history: recentHistory,
    );
  }
}