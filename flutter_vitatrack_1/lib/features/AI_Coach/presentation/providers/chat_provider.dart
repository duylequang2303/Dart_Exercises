import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/user_health_context.dart';
import 'ai_coach_dependencies_provider.dart';

// ─── State ────────────────────────────────────────────────────

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref) : super(const ChatState()) {
    _loadChatHistory();
  }

  // Mock context - sau này thay bằng dữ liệu thực từ health feature
  UserHealthContext get _healthContext => const UserHealthContext(
        stepsToday: 8290,
        caloriesBurned: 450,
        waterIntakeMl: 1800,
        sleepHours: 7.5,
        heartRateBpm: 72,
        dailyStepsGoal: 10000,
        dailyCaloriesGoal: 700,
        dailyWaterGoalMl: 2500,
      );

  Future<void> _loadChatHistory() async {
    try {
      final useCase = _ref.read(getChatHistoryUseCaseProvider);
      final history = await useCase.execute();
      if (history.isEmpty) {
        _addWelcomeMessage();
      } else {
        state = state.copyWith(messages: history);
      }
    } catch (e) {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    final context = _healthContext;
    final welcomeMsg = ChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      content: 'Chào bạn! Tôi là VitaTrack AI Coach. '
          'Dựa trên dữ liệu hôm nay, bạn đã đi được '
          '${context.stepsToday} bước. Tôi có thể giúp gì cho bạn?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [welcomeMsg]);
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    // Thêm tin user vào list ngay lập tức
    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: messageText.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      errorMessage: null,
    );

    try {
      final useCase = _ref.read(sendChatMessageUseCaseProvider);
      final aiResponse = await useCase.execute(
        message: messageText,
        context: _healthContext,
        history: state.messages,
      );

      state = state.copyWith(
        messages: [...state.messages, aiResponse],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể kết nối AI Coach. Vui lòng thử lại.',
      );
    }
  }

  Future<void> clearChat() async {
    try {
      final repository = _ref.read(aiCoachRepositoryProvider);
      await repository.clearChatHistory();
      state = const ChatState();
      _addWelcomeMessage();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Không thể xóa lịch sử chat.');
    }
  }

  void dismissError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ─── Provider ─────────────────────────────────────────────────

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});