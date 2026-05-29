import '../entities/chat_message.dart';
import '../entities/health_analysis.dart';
import '../entities/coach_plan.dart';
import '../entities/user_health_context.dart';

/// Abstract interface - tầng trên chỉ biết file này, không biết implementation
abstract class AiCoachRepository {
  Future<ChatMessage> sendMessage({
    required String message,
    required UserHealthContext context,
    required List<ChatMessage> history,
  });

  Future<HealthAnalysis> getHealthAnalysis(UserHealthContext context);

  Future<CoachPlan> getCoachPlan(UserHealthContext context);

  Future<void> updateTaskCompletion({
    required String taskId,
    required bool isCompleted,
  });

  Future<List<ChatMessage>> getChatHistory();

  Future<void> clearChatHistory();
}