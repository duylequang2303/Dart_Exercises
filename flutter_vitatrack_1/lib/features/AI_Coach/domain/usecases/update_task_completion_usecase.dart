import '../repositories/ai_coach_repository.dart';

class UpdateTaskCompletionUseCase {
  final AiCoachRepository _repository;
  const UpdateTaskCompletionUseCase(this._repository);

  Future<void> execute({
    required String taskId,
    required bool isCompleted,
  }) async {
    return _repository.updateTaskCompletion(
      taskId: taskId,
      isCompleted: isCompleted,
    );
  }
}