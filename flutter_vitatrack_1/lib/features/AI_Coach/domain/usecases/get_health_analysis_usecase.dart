import '../entities/health_analysis.dart';
import '../entities/user_health_context.dart';
import '../repositories/ai_coach_repository.dart';

class GetHealthAnalysisUseCase {
  final AiCoachRepository _repository;
  const GetHealthAnalysisUseCase(this._repository);

  Future<HealthAnalysis> execute(UserHealthContext context) async {
    return _repository.getHealthAnalysis(context);
  }
}