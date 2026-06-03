import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/user_health_context.dart';
import 'ai_coach_dependencies_provider.dart';

import '../../../../features/health/presentation/providers/health_provider.dart';
import '../../../../features/nutrition/presentation/providers/nutrition_provider.dart';
import '../../../../features/workout/presentation/providers/workout_timer_provider.dart';

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

  // Lấy dữ liệu thực từ các providers
  UserHealthContext get _healthContext {
    final health = _ref.read(healthProvider);
    final nutrition = _ref.read(nutritionProvider);
    
    // Lấy workout history (nếu đã load thành công)
    final workoutAsync = _ref.read(workoutHistoryProvider);
    final workouts = workoutAsync.value ?? [];
    final workoutNames = workouts.map((w) => w.name).toList();

    // Lấy tên các món ăn
    final mealNames = nutrition.lichSuBuaAn.map((m) {
      final name = m['tenMonAn'] ?? m['ten'] ?? 'Món ăn';
      final calo = m['calo'] ?? 0;
      return '$name ($calo kcal)';
    }).toList();

    // Tính toán macro
    double totalP = 0, totalC = 0, totalF = 0;
    for (var m in nutrition.lichSuBuaAn) {
      totalP += (m['protein'] as num?)?.toDouble() ?? 0;
      totalC += (m['carbs'] as num?)?.toDouble() ?? 0;
      totalF += (m['fat'] as num?)?.toDouble() ?? 0;
    }

    // Tính calo đốt được từ các bài tập
    final calBurned = workouts.fold<int>(0, (sum, w) => sum + w.calories.toInt());

    return UserHealthContext(
      stepsToday: health.steps,
      caloriesBurned: nutrition.caloDaNap,
      activeCaloriesBurned: calBurned,
      waterIntakeMl: nutrition.soLyNuoc * 250, // 250ml mỗi ly
      sleepHours: health.sleepHours, // Lấy thẳng số giờ ngủ từ HealthMetric
      heartRateBpm: health.heartRate,
      dailyStepsGoal: 10000,
      dailyCaloriesGoal: nutrition.caloMucTieu > 0 ? nutrition.caloMucTieu : 2000,
      dailyWaterGoalMl: 2500,
      proteinGram: totalP,
      carbsGram: totalC,
      fatGram: totalF,
      mealNames: mealNames,
      workoutNames: workoutNames.isEmpty && calBurned > 0 ? ['Có tập luyện ($calBurned kcal)'] : workoutNames,
    );
  }

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