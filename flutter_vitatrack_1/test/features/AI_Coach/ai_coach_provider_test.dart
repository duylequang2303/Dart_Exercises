import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/domain/entities/chat_message.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/domain/entities/user_health_context.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/domain/entities/health_analysis.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/domain/entities/coach_plan.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/domain/repositories/ai_coach_repository.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/domain/usecases/get_chat_history_usecase.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/domain/usecases/send_chat_message_usecase.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/chat_provider.dart';

class FakeAiCoachRepository implements AiCoachRepository {
  List<ChatMessage> history = [];

  @override
  Future<List<ChatMessage>> getChatHistory() async => history;

  @override
  Future<void> clearChatHistory() async {
    history.clear();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String message,
    required UserHealthContext context,
    required List<ChatMessage> history,
  }) async {
    if (message == 'error') {
      throw Exception('Lỗi kết nối');
    }
    final aiResponse = ChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      content: 'Phản hồi từ AI cho: $message',
      isUser: false,
      timestamp: DateTime.now(),
    );
    return aiResponse;
  }

  @override
  Future<HealthAnalysis> getHealthAnalysis(UserHealthContext context) async {
    return const HealthAnalysis(
      summary: 'Phân tích sức khỏe',
      diemTot: [],
      canCaiThien: [],
      bmiDanhGia: 'Bình thường',
      sleepQualityChange: 0,
      waterIntake: 0,
      waterRemaining: 0,
      caloriesBurned: 0,
      caloriesGoalPercent: 0,
      weeklyActivity: {},
    );
  }

  @override
  Future<CoachPlan> getCoachPlan(UserHealthContext context) async {
    return const CoachPlan(dailyTasks: [], weeklyGoals: []);
  }

  @override
  Future<void> updateTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {}
}

class FakeGetChatHistoryUseCase extends GetChatHistoryUseCase {
  final AiCoachRepository repo;
  FakeGetChatHistoryUseCase(this.repo) : super(repo);

  @override
  Future<List<ChatMessage>> execute() => repo.getChatHistory();
}

class FakeSendChatMessageUseCase extends SendChatMessageUseCase {
  final AiCoachRepository repo;
  FakeSendChatMessageUseCase(this.repo) : super(repo);

  @override
  Future<ChatMessage> execute({
    required String message,
    required UserHealthContext context,
    required List<ChatMessage> history,
  }) {
    return repo.sendMessage(
      message: message,
      context: context,
      history: history,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeAiCoachRepository fakeRepository;
  late FakeGetChatHistoryUseCase fakeGetHistory;
  late FakeSendChatMessageUseCase fakeSendMessage;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeAiCoachRepository();
    fakeGetHistory = FakeGetChatHistoryUseCase(fakeRepository);
    fakeSendMessage = FakeSendChatMessageUseCase(fakeRepository);

    container = ProviderContainer(
      overrides: [
        aiCoachRepositoryProvider.overrideWithValue(fakeRepository),
        getChatHistoryUseCaseProvider.overrideWithValue(fakeGetHistory),
        sendChatMessageUseCaseProvider.overrideWithValue(fakeSendMessage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Tự động tải lịch sử chat và thêm tin nhắn chào mừng nếu lịch sử trống', () async {
    // Đọc provider trước để kích hoạt khởi tạo
    container.read(chatProvider);
    
    // Đợi khởi chạy _loadChatHistory hoàn tất
    await Future.delayed(const Duration(milliseconds: 50));

    final state = container.read(chatProvider);
    expect(state.messages.length, 1);
    expect(state.messages.first.content, contains('Chào bạn! Tôi là VitaTrack AI Coach.'));
    expect(state.messages.first.isUser, false);
  });

  test('Tải lịch sử thành công nếu có tin nhắn cũ', () async {
    fakeRepository.history = [
      ChatMessage(
        id: '1',
        content: 'Chào AI',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    ];

    // Khởi tạo lại container để load lịch sử mới
    final newContainer = ProviderContainer(
      overrides: [
        aiCoachRepositoryProvider.overrideWithValue(fakeRepository),
        getChatHistoryUseCaseProvider.overrideWithValue(fakeGetHistory),
        sendChatMessageUseCaseProvider.overrideWithValue(fakeSendMessage),
      ],
    );

    // Kích hoạt khởi tạo
    newContainer.read(chatProvider);
    await Future.delayed(const Duration(milliseconds: 50));

    final state = newContainer.read(chatProvider);
    expect(state.messages.length, 1);
    expect(state.messages.first.content, 'Chào AI');
    expect(state.messages.first.isUser, true);

    newContainer.dispose();
  });

  test('sendMessage() thêm tin nhắn của user và nhận phản hồi từ AI', () async {
    // Kích hoạt khởi tạo
    final notifier = container.read(chatProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 50));

    final future = notifier.sendMessage('Tôi muốn giảm cân');

    // Kiểm tra trạng thái loading và tin nhắn user được thêm ngay lập tức
    expect(container.read(chatProvider).isLoading, true);
    expect(container.read(chatProvider).messages.last.content, 'Tôi muốn giảm cân');
    expect(container.read(chatProvider).messages.last.isUser, true);

    await future;

    // Kiểm tra đã nhận phản hồi từ AI
    final state = container.read(chatProvider);
    expect(state.isLoading, false);
    expect(state.messages.length, 3); // Chào mừng (1) + User (2) + AI (3)
    expect(state.messages.last.content, contains('Phản hồi từ AI cho: Tôi muốn giảm cân'));
    expect(state.messages.last.isUser, false);
  });

  test('sendMessage() thất bại cập nhật thông báo lỗi', () async {
    // Kích hoạt khởi tạo
    final notifier = container.read(chatProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 50));

    await notifier.sendMessage('error');

    final state = container.read(chatProvider);
    expect(state.isLoading, false);
    expect(state.errorMessage, 'Không thể kết nối AI Coach. Vui lòng thử lại.');
  });

  test('clearChat() xóa sạch lịch sử trò chuyện và đưa về tin chào mừng', () async {
    // Kích hoạt khởi tạo
    final notifier = container.read(chatProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 50));

    // Gửi tin nhắn
    await notifier.sendMessage('Hello');
    expect(container.read(chatProvider).messages.length, 3);

    // Xóa lịch sử
    await notifier.clearChat();

    final state = container.read(chatProvider);
    expect(state.messages.length, 1);
    expect(state.messages.first.content, contains('Chào bạn! Tôi là VitaTrack AI Coach.'));
  });
}
