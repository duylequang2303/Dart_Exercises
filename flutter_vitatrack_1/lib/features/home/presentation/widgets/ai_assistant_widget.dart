import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';

import 'package:flutter_vitatrack_1/features/home/presentation/widgets/workout_plan_bottom_sheet.dart';
import 'package:flutter_vitatrack_1/features/home/presentation/widgets/meal_plan_bottom_sheet.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/analysis_plan_provider.dart';


class AiAssistantWidget extends ConsumerStatefulWidget {
  const AiAssistantWidget({super.key});

  @override
  ConsumerState<AiAssistantWidget> createState() => _AiAssistantWidgetState();
}

class _AiAssistantWidgetState extends ConsumerState<AiAssistantWidget> {
  bool _isLoading = false;
  String _loadingMessage = '';

  Future<void> _handleGenerateWorkout() async {
    final contextData = ref.read(userHealthContextProvider);
    setState(() {
      _isLoading = true;
      _loadingMessage = 'AI đang lên giáo án phù hợp với mục tiêu ${contextData.mucTieu ?? "của bạn"}...';
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
    final contextData = ref.read(userHealthContextProvider);
    final remainingCal = contextData.dailyCaloriesGoal - contextData.caloriesBurned;
    final targetCal = remainingCal.clamp(300, contextData.dailyCaloriesGoal);

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Còn $remainingCal kcal hôm nay, AI đang lên thực đơn...';
    });

    try {
      final apiKey = kGroqApiKey;
      final planner = ref.read(aiPlannerDataSourceProvider);
      final meals = await planner.generateMealPlan(apiKey, targetCal.toInt());

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (meals != null && meals.isNotEmpty) {
        _showMealPlanBottomSheet(meals, targetCal.toInt());
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
