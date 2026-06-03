import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/AI_Coach/presentation/providers/ai_coach_dependencies_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/workout_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/screens/live_workout_screen.dart';

class WorkoutPlanBottomSheetContent extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialResult;

  const WorkoutPlanBottomSheetContent({
    Key? key,
    required this.initialResult,
  }) : super(key: key);

  @override
  ConsumerState<WorkoutPlanBottomSheetContent> createState() => _WorkoutPlanBottomSheetContentState();
}

class _WorkoutPlanBottomSheetContentState extends ConsumerState<WorkoutPlanBottomSheetContent> {
  late Map<String, dynamic> _result;
  late List<ExerciseEntity> _exercises;
  bool _isRegenerating = false;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    _parseExercises();
  }

  void _parseExercises() {
    _exercises = (_result['exercises'] as List).map((e) => ExerciseEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString() + (e['name'] ?? ''),
      name: e['name'] ?? 'Động tác',
      instructions: e['instructions'],
      duration: Duration(seconds: e['duration'] ?? 0),
      reps: e['reps'] ?? 0,
      sets: e['sets'] ?? 1,
      restSeconds: e['restSeconds'] ?? 0,
    )).toList();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleRegenerate() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) return;

    setState(() {
      _isRegenerating = true;
    });

    try {
      final apiKey = kGroqApiKey;
      final planner = ref.read(aiPlannerDataSourceProvider);
      final newResult = await planner.generateWorkoutPlan(apiKey, userFeedback: feedback);

      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
        if (newResult != null && newResult['exercises'] != null) {
          _result = newResult;
          _parseExercises();
          _feedbackController.clear();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật giáo án theo yêu cầu!'), backgroundColor: VitaTrackTheme.mauThanhCong));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tạo lại giáo án lúc này.')));
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRegenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final standardName = _result['standardName'] ?? 'Giáo án tập luyện';
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: VitaTrackTheme.mauNen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: VitaTrackTheme.mauCardNhat, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Giáo án AI đề xuất', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(standardName, style: const TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          
          if (_isRegenerating)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: VitaTrackTheme.mauChinh),
                    SizedBox(height: 16),
                    Text('AI đang điều chỉnh lại giáo án...', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final ex = _exercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: VitaTrackTheme.mauCard, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: VitaTrackTheme.mauChinh.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.fitness_center, color: VitaTrackTheme.mauChinh),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.name, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              if (ex.reps > 0)
                                Text('${ex.sets} hiệp x ${ex.reps} lần', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13))
                              else
                                Text('${ex.sets} hiệp x ${ex.duration.inSeconds}s', style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13)),
                              if (ex.instructions != null && ex.instructions!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(ex.instructions!, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12, fontStyle: FontStyle.italic)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
          // Khu vực nhập phản hồi
          Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _feedbackController,
                        style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'VD: Khó hơn, bỏ bài nhảy vì đau gối...',
                          hintStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14),
                          filled: true,
                          fillColor: VitaTrackTheme.mauCard,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _isRegenerating ? null : _handleRegenerate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: VitaTrackTheme.mauChinh, shape: BoxShape.circle),
                        child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy', style: TextStyle(color: VitaTrackTheme.mauChuPhu)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: VitaTrackTheme.mauChinh),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isRegenerating ? null : () async {
                           final plan = WorkoutEntity(
                             id: '${DateTime.now().millisecondsSinceEpoch}',
                             name: standardName,
                             duration: Duration.zero,
                             exercises: _exercises,
                             calories: 0,
                             steps: 0,
                             iconCodePoint: Icons.auto_awesome.codePoint,
                             type: _result['type'] ?? 'cardio',
                           );
                           await ref.read(workoutRepositoryProvider).saveWorkoutPlan(plan);
                           ref.invalidate(workoutPlansProvider);
                           if (!mounted) return;
                           Navigator.pop(context);
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu giáo án vào tab Hoạt động!'), backgroundColor: VitaTrackTheme.mauThanhCong));
                        },
                        child: const Text('Lưu', style: TextStyle(color: VitaTrackTheme.mauChinh, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VitaTrackTheme.mauThanhCong,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isRegenerating ? null : () async {
                          Navigator.pop(context); // đóng bottom sheet
                          
                          // Mở màn hình tập luyện
                          await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveWorkoutScreen(
                                exercises: _exercises,
                                tenBaiTap: standardName,
                                iconBaiTap: Icons.auto_awesome,
                              ),
                            ),
                          );
                        },
                        child: const Text('Bắt đầu tập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
