import '../../domain/entities/chat_message.dart';
import '../../domain/entities/health_analysis.dart';
import '../../domain/entities/coach_plan.dart';
import '../../domain/entities/user_health_context.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../datasources/groq_api_datasource.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/coach_plan_model.dart';

/// Implementation thực tế của AiCoachRepository
/// Điều phối giữa Groq API và local storage
class AiCoachRepositoryImpl implements AiCoachRepository {
  final GroqApiDataSource _groqDataSource;
  final LocalStorageDataSource _localDataSource;

  AiCoachRepositoryImpl({
    required GroqApiDataSource groqDataSource,
    required LocalStorageDataSource localDataSource,
  })  : _groqDataSource = groqDataSource,
        _localDataSource = localDataSource;

  // ─── Chat ─────────────────────────────────────────────────

  @override
  Future<ChatMessage> sendMessage({
    required String message,
    required UserHealthContext context,
    required List<ChatMessage> history,
  }) async {
    final historyModels = history
        .map((msg) => ChatMessageModel.fromEntity(msg))
        .toList();

    final responseModel = await _groqDataSource.sendChatMessage(
      userMessage: message,
      history: historyModels,
      context: context,
    );

    // Lưu lịch sử (gồm tin user + tin AI) vào local
    final updatedHistory = [
      ...historyModels,
      ChatMessageModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_user',
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
      responseModel,
    ];
    await _localDataSource.saveChatHistory(updatedHistory);

    return responseModel;
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    return _localDataSource.getChatHistory();
  }

  @override
  Future<void> clearChatHistory() async {
    await _localDataSource.clearChatHistory();
  }

  // ─── Health Analysis ──────────────────────────────────────

  @override
  Future<HealthAnalysis> getHealthAnalysis(UserHealthContext context) async {
    return _groqDataSource.getHealthAnalysis(context);
  }

  // ─── Coach Plan ───────────────────────────────────────────

  @override
  Future<CoachPlan> getCoachPlan(UserHealthContext context) async {
    final plan = await _groqDataSource.getCoachPlan(context);

    // Giữ lại trạng thái task đã tick khi refresh
    final tasksWithState = _localDataSource.applyStoredCompletionState(
      plan.dailyTasks.cast<DailyTaskModel>(),
    );

    return CoachPlanModel(
      dailyTasks: tasksWithState,
      weeklyGoals: plan.weeklyGoals,
    );
  }

  @override
  Future<void> updateTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _localDataSource.updateTaskCompletion(
      taskId: taskId,
      isCompleted: isCompleted,
    );
  }
}