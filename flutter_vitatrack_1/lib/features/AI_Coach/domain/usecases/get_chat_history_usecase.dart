import '../entities/chat_message.dart';
import '../repositories/ai_coach_repository.dart';

class GetChatHistoryUseCase {
  final AiCoachRepository _repository;
  const GetChatHistoryUseCase(this._repository);

  Future<List<ChatMessage>> execute() async {
    return _repository.getChatHistory();
  }
}