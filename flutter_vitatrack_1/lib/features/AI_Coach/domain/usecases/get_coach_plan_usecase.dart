import '../entities/coach_plan.dart';
import '../entities/user_health_context.dart';
import '../repositories/ai_coach_repository.dart';

class GetCoachPlanUseCase {
  final AiCoachRepository _repository;
  const GetCoachPlanUseCase(this._repository);

  Future<CoachPlan> execute(UserHealthContext context) async {
    return _repository.getCoachPlan(context);
  }
}