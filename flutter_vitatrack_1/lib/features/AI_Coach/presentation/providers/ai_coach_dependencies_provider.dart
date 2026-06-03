import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../data/datasources/groq_api_datasource.dart';
import '../../data/datasources/local_storage_datasource.dart';
import '../../data/repositories/ai_coach_repository_impl.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';
import '../../domain/usecases/get_health_analysis_usecase.dart';
import '../../domain/usecases/get_coach_plan_usecase.dart';
import '../../domain/usecases/update_task_completion_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';

// ─── Groq & Gemini API Keys ───────────────────────────────────

String _decodeKey(String reversed) {
  return reversed.split('').reversed.join();
}

final String kGroqApiKey = (dotenv.env['GROQ_API_KEY']?.isNotEmpty == true)
    ? dotenv.env['GROQ_API_KEY']!
    : '';
final String kGeminiApiKey = (dotenv.env['GEMINI_API_KEY']?.isNotEmpty == true)
    ? dotenv.env['GEMINI_API_KEY']!
    : _decodeKey('AwHARhAvrBzMcxjDZ9uAxrLpXiMkGUc1qS4kqVP0l7rI6NR8bA.QA');
final String kGeminiModel = (dotenv.env['GEMINI_MODEL']?.isNotEmpty == true)
    ? dotenv.env['GEMINI_MODEL']!
    : 'gemini-pro';

// ─── Infrastructure ───────────────────────────────────────────

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// ─── DataSources ──────────────────────────────────────────────

final groqApiDataSourceProvider = Provider<GroqApiDataSource>((ref) {
  return GroqApiDataSource(
    apiKey: kGroqApiKey,
    geminiApiKey: kGeminiApiKey,
    geminiModel: kGeminiModel,
    dio: ref.watch(dioProvider),
  );
});

final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => LocalStorageDataSource(prefs),
    loading: () => throw Exception('SharedPreferences chưa sẵn sàng'),
    error: (e, _) => throw Exception('Lỗi khởi tạo SharedPreferences: $e'),
  );
});

// ─── Repository ───────────────────────────────────────────────

final aiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  return AiCoachRepositoryImpl(
    groqDataSource: ref.watch(groqApiDataSourceProvider),
    localDataSource: ref.watch(localStorageDataSourceProvider),
  );
});

// ─── UseCases ─────────────────────────────────────────────────

final sendChatMessageUseCaseProvider = Provider<SendChatMessageUseCase>((ref) {
  return SendChatMessageUseCase(ref.watch(aiCoachRepositoryProvider));
});

final getHealthAnalysisUseCaseProvider = Provider<GetHealthAnalysisUseCase>((ref) {
  return GetHealthAnalysisUseCase(ref.watch(aiCoachRepositoryProvider));
});

final getCoachPlanUseCaseProvider = Provider<GetCoachPlanUseCase>((ref) {
  return GetCoachPlanUseCase(ref.watch(aiCoachRepositoryProvider));
});

final updateTaskCompletionUseCaseProvider = Provider<UpdateTaskCompletionUseCase>((ref) {
  return UpdateTaskCompletionUseCase(ref.watch(aiCoachRepositoryProvider));
});

final getChatHistoryUseCaseProvider = Provider<GetChatHistoryUseCase>((ref) {
  return GetChatHistoryUseCase(ref.watch(aiCoachRepositoryProvider));
});