import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/screens/live_workout_screen.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';
import 'package:flutter_vitatrack_1/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:flutter_vitatrack_1/features/home/presentation/widgets/workout_plan_bottom_sheet.dart';
import 'package:flutter_vitatrack_1/features/home/presentation/widgets/meal_plan_bottom_sheet.dart';


class AiAssistantWidget extends ConsumerStatefulWidget {
  const AiAssistantWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<AiAssistantWidget> createState() => _AiAssistantWidgetState();
}

class _AiAssistantWidgetState extends ConsumerState<AiAssistantWidget> {
  bool _isLoading = false;
  String _loadingMessage = '';

  Future<void> _handleGenerateWorkout() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Đang nhào nặn giáo án tập...';
    });

    try {
      final apiKey = kGroqApiKey;
      final planner = ref.read(aiPlannerDataSourceProvider);
      
      final result = await planner.generateWorkoutPlan(apiKey);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result != null && result['exercises'] != null) {
        _showWorkoutPlanBottomSheet(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI không thể lên giáo án lúc này.'))
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showWorkoutPlanBottomSheet(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return WorkoutPlanBottomSheetContent(initialResult: result);
      },
    );
  }

  Future<void> _handleGenerateMealPlan() async {
    final authState = ref.read(authProvider);
    final targetCalo = authState.nguoiDung?.caloMucTieu ?? 2000;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'AI đang lên thực đơn $targetCalo kcal...';
    });

    try {
      final apiKey = kGroqApiKey;
      final planner = ref.read(aiPlannerDataSourceProvider);
      final meals = await planner.generateMealPlan(apiKey, targetCalo);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (meals != null && meals.isNotEmpty) {
        _showMealPlanBottomSheet(meals, targetCalo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI không thể lên thực đơn lúc này.'))
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showMealPlanBottomSheet(List<Map<String, dynamic>> meals, int targetCalo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return MealPlanBottomSheetContent(initialMeals: meals, targetCalo: targetCalo);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: VitaTrackTheme.mauChinh.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
            const SizedBox(height: 16),
            Text(_loadingMessage, style: const TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VitaTrackTheme.mauCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VitaTrackTheme.mauThanhCong.withValues(alpha: 0.2)),
        gradient: LinearGradient(
          colors: [VitaTrackTheme.mauCard, VitaTrackTheme.mauChinh.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: VitaTrackTheme.mauChinh),
              const SizedBox(width: 8),
              const Text('Trợ lý AI thông minh', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Để AI lên kế hoạch tập luyện và ăn uống giúp bạn!', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _handleGenerateMealPlan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: VitaTrackTheme.mauThanhCong.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      children: [
                        Icon(Icons.restaurant, color: VitaTrackTheme.mauThanhCong, size: 28),
                        SizedBox(height: 8),
                        Text('Ăn gì?', style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _handleGenerateWorkout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      children: [
                        Icon(Icons.fitness_center, color: VitaTrackTheme.mauChinh, size: 28),
                        SizedBox(height: 8),
                        Text('Tập gì?', style: TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
