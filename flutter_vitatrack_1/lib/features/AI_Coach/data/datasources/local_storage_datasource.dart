import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message_model.dart';
import '../models/coach_plan_model.dart';

/// Xử lý lưu trữ local: lịch sử chat + trạng thái task đã tick
class LocalStorageDataSource {
  static const String _chatHistoryKey = 'ai_coach_chat_history';
  static const String _taskCompletionKey = 'ai_coach_task_completion';
  static const int _maxStoredMessages = 50;

  final SharedPreferences _prefs;
  LocalStorageDataSource(this._prefs);

  // ─── Chat History ─────────────────────────────────────────

  List<ChatMessageModel> getChatHistory() {
    final jsonString = _prefs.getString(_chatHistoryKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _prefs.remove(_chatHistoryKey);
      return [];
    }
  }

  Future<void> saveChatHistory(List<ChatMessageModel> messages) async {
    // Giới hạn số tin lưu để tránh tốn storage
    final messagesToSave = messages.length > _maxStoredMessages
        ? messages.sublist(messages.length - _maxStoredMessages)
        : messages;

    final jsonList = messagesToSave.map((m) => m.toJson()).toList();
    await _prefs.setString(_chatHistoryKey, jsonEncode(jsonList));
  }

  Future<void> clearChatHistory() async {
    await _prefs.remove(_chatHistoryKey);
  }

  // ─── Task Completion ──────────────────────────────────────

  Map<String, bool> getTaskCompletionState() {
    final jsonString = _prefs.getString(_taskCompletionKey);
    if (jsonString == null || jsonString.isEmpty) return {};

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      return {};
    }
  }

  Future<void> updateTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    final currentState = getTaskCompletionState();
    currentState[taskId] = isCompleted;
    await _prefs.setString(_taskCompletionKey, jsonEncode(currentState));
  }

  /// Áp dụng trạng thái đã lưu vào tasks mới từ API
  /// Giữ lại task đã tick khi refresh plan
  List<DailyTaskModel> applyStoredCompletionState(List<DailyTaskModel> tasks) {
    final storedState = getTaskCompletionState();
    return tasks.map((task) {
      final storedCompletion = storedState[task.id];
      if (storedCompletion != null) {
        return DailyTaskModel(
          id: task.id,
          title: task.title,
          isCompleted: storedCompletion,
        );
      }
      return task;
    }).toList();
  }
}