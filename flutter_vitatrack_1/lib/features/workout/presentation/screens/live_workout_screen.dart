import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/live_workout_provider.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/entities/exercise_entity.dart';

class LiveWorkoutScreen extends ConsumerStatefulWidget {
  final String tenBaiTap;
  final IconData iconBaiTap;
  final String type; // 'strength' or 'cardio'
  final List<ExerciseEntity> exercises;

  const LiveWorkoutScreen({
    super.key,
    required this.tenBaiTap,
    required this.iconBaiTap,
    this.type = 'cardio',
    this.exercises = const [],
  });

  @override
  ConsumerState<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends ConsumerState<LiveWorkoutScreen> with TickerProviderStateMixin {
  bool _ended = false;
  late AnimationController _holdController;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _holdController.addListener(() {
      if (mounted) setState(() {});
      if (_holdController.value == 1.0 && !_ended) {
        _endWorkout();
      }
    });

    ref.read(workoutTimerNotifierProvider.notifier).reset();
    ref.read(workoutTimerNotifierProvider.notifier).startCountdown(3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveWorkoutProvider.notifier).init(widget.tenBaiTap);
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _endWorkout() {
    if (_ended) return;
    _ended = true;

    final liveState = ref.read(liveWorkoutProvider);
    final elapsed = ref.read(workoutElapsedProvider);

    // Tính toán calo tổng hợp và thời gian dự kiến
    double finalCalories = liveState.calories;
    Duration finalDuration = elapsed;

    if (widget.exercises.isEmpty && elapsed.inSeconds < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bài tập quá ngắn nên không được lưu vào lịch sử.'),
          backgroundColor: VitaTrackTheme.mauCanhBao,
        ),
      );
      Navigator.pop(context, false);
      return;
    }

    ref.read(workoutTimerNotifierProvider.notifier).stop(
      name: widget.tenBaiTap,
      calories: finalCalories,
      steps: liveState.stepsDelta,
      iconCodePoint: widget.iconBaiTap.codePoint,
      type: widget.type,
      exercises: widget.exercises,
      overrideDuration: finalDuration, // Dùng thời gian đã tính toán
    );

    ref.read(liveWorkoutProvider.notifier).reset();
    HapticFeedback.heavyImpact();
    
    // Hiển thị hộp thoại chúc mừng trước khi đóng
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: VitaTrackTheme.mauCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Tuyệt vời! 🎉', style: TextStyle(color: VitaTrackTheme.mauChu, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: VitaTrackTheme.mauChinh, size: 64),
            const SizedBox(height: 16),
            Text('Bạn đã hoàn thành buổi tập:', style: const TextStyle(color: VitaTrackTheme.mauChuPhu)),
            const SizedBox(height: 6),
            Text(widget.tenBaiTap, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dialogStat(_format(elapsed), 'THỜI GIAN'),
                _dialogStat('${finalCalories.toStringAsFixed(1)} kcal', 'CALORIES'),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VitaTrackTheme.mauChinh,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // đóng dialog
                  Navigator.pop(context, true); // quay lại màn hình chính
                },
                child: const Text('Tuyệt vời', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _dialogStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 10)),
      ],
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = ref.watch(workoutElapsedProvider);
    final liveState = ref.watch(liveWorkoutProvider);
    final countdownDuration = ref.watch(workoutCountdownProvider);
    int? countdown = countdownDuration?.inSeconds;

    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: countdown != null 
            ? _buildCountdown(countdown) 
            : _buildLive(elapsed, liveState),
      ),
    );
  }

  Widget _buildCountdown(int count) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Chuẩn bị', style: TextStyle(color: VitaTrackTheme.mauChuPhu.withValues(alpha: 0.5), fontSize: 24)),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            key: ValueKey(count),
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Text('$count', style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 120, fontWeight: FontWeight.bold, height: 1)),
              );
            },
          ),
        ],
      ),
    );
  }


  // Giao diện phẳng cũ cho chạy bộ / đạp xe liên tục
  Widget _buildLive(Duration elapsed, LiveWorkoutState liveState) {
    final nameLower = widget.tenBaiTap.toLowerCase();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.iconBaiTap, color: VitaTrackTheme.mauChinh, size: 24),
              const SizedBox(width: 8),
              Text(widget.tenBaiTap, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_format(elapsed), style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 80, fontWeight: FontWeight.w200, height: 1)),
              const Text('THỜI GIAN THỰC TẾ', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14, letterSpacing: 2)),
              const SizedBox(height: 50),
              
              _buildMetrics(elapsed, liveState, nameLower),

              if (liveState.isStepBased && !liveState.isMoving && elapsed.inSeconds > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: VitaTrackTheme.mauCanhBao.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VitaTrackTheme.mauCanhBao.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pause_circle_outline, color: VitaTrackTheme.mauCanhBao, size: 16),
                        SizedBox(width: 6),
                        Text('Đang đứng yên - Tạm dừng đếm bước', style: TextStyle(color: VitaTrackTheme.mauCanhBao, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (liveState.isPaused)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VitaTrackTheme.mauThanhCong,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        ref.read(liveWorkoutProvider.notifier).resume();
                        ref.read(workoutTimerNotifierProvider.notifier).resume();
                      },
                      icon: const Icon(Icons.play_arrow, color: VitaTrackTheme.mauNen),
                      label: const Text('TIẾP TỤC TẬP', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold)),
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VitaTrackTheme.mauCanhBao,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        ref.read(liveWorkoutProvider.notifier).pause();
                        ref.read(workoutTimerNotifierProvider.notifier).pause();
                      },
                      icon: const Icon(Icons.pause, color: VitaTrackTheme.mauNen),
                      label: const Text('NGHỈ GIỮA CHẶNG', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTapDown: (_) {
                      if (!_ended) {
                        HapticFeedback.lightImpact();
                        _holdController.forward();
                      }
                    },
                    onTapUp: (_) { if (!_ended) _holdController.reverse(); },
                    onTapCancel: () { if (!_ended) _holdController.reverse(); },
                    child: SizedBox(
                      width: 80, height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircularProgressIndicator(value: 1.0, strokeWidth: 4, color: VitaTrackTheme.mauCard),
                          CircularProgressIndicator(value: _holdController.value, strokeWidth: 6, backgroundColor: Colors.transparent, color: VitaTrackTheme.mauNguyHiem, strokeCap: StrokeCap.round),
                          Container(width: 56, height: 56, decoration: BoxDecoration(color: VitaTrackTheme.mauNguyHiem, shape: BoxShape.circle), child: const Icon(Icons.stop_rounded, color: VitaTrackTheme.mauNen, size: 28)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(opacity: _holdController.value > 0 ? 0.0 : 1.0, duration: const Duration(milliseconds: 200), child: const Text('Nhấn giữ nút đỏ để kết thúc', style: TextStyle(color: VitaTrackTheme.mauChuPhu))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMetrics(Duration elapsed, LiveWorkoutState liveState, String nameLower) {
    if (liveState.isStepBased || nameLower.contains('bóng') || nameLower.contains('đá')) {
      final double distanceKm = liveState.stepsDelta * 0.0007;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, liveState.calories.toStringAsFixed(1), 'KCAL'),
          Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
          _stat(Icons.do_not_step, VitaTrackTheme.mauThanhCong, '${liveState.stepsDelta}', 'BƯỚC'),
          Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
          _stat(Icons.trending_up, VitaTrackTheme.mauChinh, distanceKm.toStringAsFixed(2), 'KM'),
        ],
      );
    }
    
    if (nameLower.contains('đạp') || nameLower.contains('bike') || nameLower.contains('ride')) {
      final double distanceKm = elapsed.inSeconds * 0.004;
      final double speedKmh = elapsed.inSeconds > 2 ? 16.5 : 0.0;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, (elapsed.inSeconds * 0.12).toStringAsFixed(1), 'KCAL'),
          Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
          _stat(Icons.speed, VitaTrackTheme.mauThanhCong, speedKmh.toStringAsFixed(1), 'KM/H'),
          Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
          _stat(Icons.pedal_bike, VitaTrackTheme.mauChinh, distanceKm.toStringAsFixed(2), 'KM'),
        ],
      );
    }

    if (nameLower.contains('bơi') || nameLower.contains('pool') || nameLower.contains('swim')) {
      final double distanceM = elapsed.inSeconds * 0.5;
      final int laps = (distanceM / 50).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, (elapsed.inSeconds * 0.15).toStringAsFixed(1), 'KCAL'),
          Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
          _stat(Icons.pool, VitaTrackTheme.mauThanhCong, '$laps', 'VÒNG BỂ'),
          Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
          _stat(Icons.straighten, VitaTrackTheme.mauChinh, '${distanceM.toInt()}', 'MÉT'),
        ],
      );
    }

    if (nameLower.contains('yoga') || nameLower.contains('thiền') || nameLower.contains('meditation') || nameLower.contains('improvement')) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, (elapsed.inSeconds * 0.05).toStringAsFixed(1), 'KCAL'),
          Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
          _stat(Icons.spa, VitaTrackTheme.mauThanhCong, 'Thư giãn', 'TRẠNG THÁI'),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, (elapsed.inSeconds * 0.1).toStringAsFixed(1), 'KCAL'),
        Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
        _stat(Icons.fitness_center, VitaTrackTheme.mauThanhCong, 'Trung bình', 'CƯỜNG ĐỘ'),
      ],
    );
  }

  Widget _stat(IconData icon, Color color, String value, String unit) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 32, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11, letterSpacing: 1)),
      ],
    );
  }
}
