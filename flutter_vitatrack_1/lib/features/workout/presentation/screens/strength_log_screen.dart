import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';

class StrengthLogScreen extends ConsumerStatefulWidget {
  final String workoutName;
  final List<ExerciseEntity> exercises;

  const StrengthLogScreen({
    super.key,
    required this.workoutName,
    this.exercises = const [],
  });

  @override
  ConsumerState<StrengthLogScreen> createState() => _StrengthLogScreenState();
}

class _StrengthLogScreenState extends ConsumerState<StrengthLogScreen> {
  late List<Map<String, TextEditingController>> _exerciseControllers;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exerciseControllers = widget.exercises.map((ex) {
      return {
        'sets': TextEditingController(text: ex.sets > 0 ? ex.sets.toString() : ''),
        'reps': TextEditingController(text: ex.reps > 0 ? ex.reps.toString() : ''),
        'weight': TextEditingController(),
      };
    }).toList();
  }

  @override
  void dispose() {
    for (var controllers in _exerciseControllers) {
      controllers['sets']?.dispose();
      controllers['reps']?.dispose();
      controllers['weight']?.dispose();
    }
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveWorkout() async {
    final durationMinutes = int.tryParse(_durationController.text) ?? 0;
    if (durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập thời gian tập hợp lệ'), backgroundColor: VitaTrackTheme.mauNguyHiem),
      );
      return;
    }

    final profileWeight = ref.read(profileProvider).profile?.canNang ?? 70.0;
    // MET value for strength training = 5.0
    // calories = MET × weight_kg × (duration_minutes / 60)
    final double calories = 5.0 * profileWeight * (durationMinutes / 60.0);

    // Build the final exercise list from inputs
    final List<ExerciseEntity> loggedExercises = [];
    for (int i = 0; i < widget.exercises.length; i++) {
      final ex = widget.exercises[i];
      final setsStr = _exerciseControllers[i]['sets']?.text ?? '';
      final repsStr = _exerciseControllers[i]['reps']?.text ?? '';

      final int sets = int.tryParse(setsStr) ?? ex.sets;
      final int reps = int.tryParse(repsStr) ?? ex.reps;

      loggedExercises.add(ex.copyWith(sets: sets, reps: reps));
    }

    ref.read(workoutTimerNotifierProvider.notifier).stop(
      name: widget.workoutName,
      calories: calories,
      steps: 0,
      iconCodePoint: Icons.fitness_center.codePoint,
      type: 'strength',
      exercises: loggedExercises,
      overrideDuration: Duration(minutes: durationMinutes),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lưu bài tập ${widget.workoutName}!'), backgroundColor: VitaTrackTheme.mauThanhCong),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      appBar: AppBar(
        backgroundColor: VitaTrackTheme.mauNen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VitaTrackTheme.mauChu),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.workoutName, style: const TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nhật ký tập luyện', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Nhập kết quả thực tế bạn vừa tập.', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14)),
              const SizedBox(height: 24),
              
              ...List.generate(widget.exercises.length, (index) {
                final ex = widget.exercises[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VitaTrackTheme.mauCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.name, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput('Hiệp', _exerciseControllers[index]['sets']!),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInput('Cái/Giây', _exerciseControllers[index]['reps']!),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildInput('Tạ (kg)', _exerciseControllers[index]['weight']!, hint: 'Tự trọng'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Text('Thông tin chung', style: TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: VitaTrackTheme.mauChu),
                decoration: InputDecoration(
                  labelText: 'Thời gian tập (phút)',
                  labelStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                  filled: true,
                  fillColor: VitaTrackTheme.mauCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: VitaTrackTheme.mauChu),
                decoration: InputDecoration(
                  labelText: 'Ghi chú (Tùy chọn)',
                  labelStyle: const TextStyle(color: VitaTrackTheme.mauChuPhu),
                  filled: true,
                  fillColor: VitaTrackTheme.mauCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VitaTrackTheme.mauChinh,
                    foregroundColor: VitaTrackTheme.mauNen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveWorkout,
                  child: const Text('Lưu buổi tập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: VitaTrackTheme.mauChu),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: VitaTrackTheme.mauChuPhu.withValues(alpha: 0.5), fontSize: 12),
            filled: true,
            fillColor: VitaTrackTheme.mauCardNhat,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
