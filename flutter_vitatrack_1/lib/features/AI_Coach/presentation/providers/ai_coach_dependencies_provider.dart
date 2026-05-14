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

// ─── Groq API Key ─────────────────────────────────────────────

String get kGroqApiKey {
  final key = dotenv.env['GROQ_API_KEY'] ?? '';
  print('=== GROQ KEY loaded: ${key.isEmpty ? "EMPTY!" : "OK"} ===');
  return key;
}

// ─── Infrastructure ───────────────────────────────────────────

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.groq.com/openai/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));
  return dio;
});

// ─── DataSources ──────────────────────────────────────────────

final groqApiDataSourceProvider = Provider<GroqApiDataSource>((ref) {
  return GroqApiDataSource(
    apiKey: kGroqApiKey,
    dio: ref.watch(dioProvider),
  );
});

// Dùng nullable để tránh throw khi SharedPreferences chưa sẵn sàng
final localStorageDataSourceProvider = Provider<LocalStorageDataSource?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => LocalStorageDataSource(prefs),
    loading: () => null,
    error: (e, _) {
      print('=== SharedPreferences ERROR: $e ===');
      return null;
    },
  );
});

// ─── Repository ───────────────────────────────────────────────

final aiCoachRepositoryProvider = Provider<AiCoachRepository?>((ref) {
  final localDataSource = ref.watch(localStorageDataSourceProvider);
  if (localDataSource == null) return null;

  return AiCoachRepositoryImpl(
    groqDataSource: ref.watch(groqApiDataSourceProvider),
    localDataSource: localDataSource,
  );
});

// ─── UseCases ─────────────────────────────────────────────────

final sendChatMessageUseCaseProvider = Provider<SendChatMessageUseCase?>((ref) {
  final repo = ref.watch(aiCoachRepositoryProvider);
  if (repo == null) return null;
  return SendChatMessageUseCase(repo);
});

final getHealthAnalysisUseCaseProvider = Provider<GetHealthAnalysisUseCase?>((ref) {
  final repo = ref.watch(aiCoachRepositoryProvider);
  if (repo == null) return null;
  return GetHealthAnalysisUseCase(repo);
});

final getCoachPlanUseCaseProvider = Provider<GetCoachPlanUseCase?>((ref) {
  final repo = ref.watch(aiCoachRepositoryProvider);
  if (repo == null) return null;
  return GetCoachPlanUseCase(repo);
});

final updateTaskCompletionUseCaseProvider = Provider<UpdateTaskCompletionUseCase?>((ref) {
  final repo = ref.watch(aiCoachRepositoryProvider);
  if (repo == null) return null;
  return UpdateTaskCompletionUseCase(repo);
});

final getChatHistoryUseCaseProvider = Provider<GetChatHistoryUseCase?>((ref) {
  final repo = ref.watch(aiCoachRepositoryProvider);
  if (repo == null) return null;
  return GetChatHistoryUseCase(repo);
});