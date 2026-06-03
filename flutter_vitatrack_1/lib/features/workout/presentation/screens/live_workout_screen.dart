import 'dart:async';
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

  // Trạng thái cho giáo án tập luyện có cấu trúc (Guided sets/reps)
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 1;
  bool _isResting = false;
  int _restTimeRemaining = 45;
  Timer? _restTimer;

  // Đếm ngược giữ thế (Cho bài tập như Plank)
  int _holdTimeRemaining = 0;
  Timer? _holdTimer;
  bool _isHoldActive = false;

  // Lượng calo giả lập tích lũy cho Gym
  double _accumulatedCalories = 0.0;

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

    ref.read(workoutElapsedProvider.notifier).reset();
    ref.read(workoutElapsedProvider.notifier).startCountdown(3);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveWorkoutProvider.notifier).init(widget.tenBaiTap);
    });

    // Nếu bài tập đầu tiên là dạng giữ thế (plank), setup thời gian giữ
    if (widget.exercises.isNotEmpty) {
      _setupCurrentExercise();
    }
  }

  void _setupCurrentExercise() {
    final currentEx = widget.exercises[_currentExerciseIndex];
    if (currentEx.duration.inSeconds > 0) {
      _holdTimeRemaining = currentEx.duration.inSeconds;
      _isHoldActive = false;
    } else {
      _holdTimeRemaining = 0;
      _isHoldActive = false;
    }
  }

  @override
  void dispose() {
    _holdController.dispose();
    _restTimer?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    setState(() => _isHoldActive = true);
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_holdTimeRemaining > 0) {
        setState(() {
          _holdTimeRemaining--;
          _accumulatedCalories += 0.15; // Plank đốt ~0.15 kcal/s
        });
      } else {
        _holdTimer?.cancel();
        setState(() => _isHoldActive = false);
        HapticFeedback.vibrate();
      }
    });
  }

  void _pauseHoldTimer() {
    _holdTimer?.cancel();
    setState(() => _isHoldActive = false);
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restTimeRemaining = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_restTimeRemaining > 0) {
        setState(() => _restTimeRemaining--);
      } else {
        _skipRest();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _isResting = false;
    });
    _setupCurrentExercise();
  }

  void _nextSet() {
    _holdTimer?.cancel();
    final currentEx = widget.exercises[_currentExerciseIndex];
    
    // Đốt calo sau mỗi hiệp
    setState(() {
      _accumulatedCalories += (currentEx.reps > 0) ? (currentEx.reps * 0.1) : 8.0;
    });

    if (_currentSetIndex < currentEx.sets) {
      // Sang hiệp tiếp theo của bài hiện tại
      setState(() => _currentSetIndex++);
      _startRestTimer(currentEx.restSeconds);
    } else {
      // Hết bài hiện tại, sang bài tập tiếp theo
      if (_currentExerciseIndex < widget.exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _currentSetIndex = 1;
        });
        _startRestTimer(currentEx.restSeconds);
      } else {
        // Hoàn thành toàn bộ bài tập
        _endWorkout();
      }
    }
  }

  void _endWorkout() {
    if (_ended) return;
    _ended = true;

    _holdTimer?.cancel();
    _restTimer?.cancel();

    final liveState = ref.read(liveWorkoutProvider);
    final elapsed = ref.read(workoutElapsedProvider);

    // Tính toán calo tổng hợp
    double finalCalories = liveState.calories;
    if (widget.exercises.isNotEmpty) {
      finalCalories = _accumulatedCalories;
    }

    ref.read(workoutElapsedProvider.notifier).stop(
      name: widget.tenBaiTap,
      calories: finalCalories,
      steps: liveState.stepsDelta,
      iconCodePoint: widget.iconBaiTap.codePoint,
      type: widget.type,
      exercises: widget.exercises,
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
                _dialogStat('${_format(elapsed)}', 'THỜI GIAN'),
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
    final countdownAsync = ref.watch(workoutCountdownProvider);
    int? countdown = countdownAsync.when(data: (v) => v, loading: () => null, error: (_, _) => null);

    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: countdown != null 
            ? _buildCountdown(countdown) 
            : (widget.exercises.isNotEmpty 
                ? _buildGuidedWorkout(elapsed, liveState)
                : _buildLive(elapsed, liveState)),
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

  // Giao diện hướng dẫn tập luyện theo Hiệp (Sets/Reps) chuyên nghiệp
  Widget _buildGuidedWorkout(Duration elapsed, LiveWorkoutState liveState) {
    final currentEx = widget.exercises[_currentExerciseIndex];

    if (_isResting) {
      return _buildRestScreen();
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(widget.iconBaiTap, color: VitaTrackTheme.mauChinh, size: 24),
                  const SizedBox(width: 8),
                  Text(widget.tenBaiTap, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                'Bài ${_currentExerciseIndex + 1}/${widget.exercises.length}',
                style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),

        // Tiến trình bài tập
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentExerciseIndex) / widget.exercises.length,
              color: VitaTrackTheme.mauChinh,
              backgroundColor: VitaTrackTheme.mauCard,
              minHeight: 6,
            ),
          ),
        ),

        const Spacer(),

        // Hiển thị tên bài tập con hiện tại
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                currentEx.name,
                style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: VitaTrackTheme.mauChinh.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Hiệp $_currentSetIndex trên ${currentEx.sets}',
                  style: const TextStyle(color: VitaTrackTheme.mauChinh, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Đo vùng chỉ số động (đếm giây giữ thế hoặc hiện reps)
        _buildGuidedMetrics(currentEx),

        const Spacer(),

        // Nút nhấn hoàn thành hiệp / Dừng tập
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
          child: Row(
            children: [
              // Nút Thoát hiểm
              GestureDetector(
                onLongPressStart: (_) {
                  HapticFeedback.lightImpact();
                  _holdController.forward();
                },
                onLongPressEnd: (_) => _holdController.reverse(),
                child: Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(color: VitaTrackTheme.mauCard, shape: BoxShape.circle),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(value: _holdController.value, color: VitaTrackTheme.mauNguyHiem, strokeWidth: 4, backgroundColor: Colors.transparent),
                      const Icon(Icons.close, color: VitaTrackTheme.mauNguyHiem),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Nút hoàn thành chính
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VitaTrackTheme.mauChinh,
                    foregroundColor: VitaTrackTheme.mauNen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 4,
                  ),
                  onPressed: _nextSet,
                  child: Text(
                    (_currentSetIndex == currentEx.sets && _currentExerciseIndex == widget.exercises.length - 1)
                        ? 'HOÀN THÀNH BÀI TẬP 🏁'
                        : 'XONG HIỆP 👍',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuidedMetrics(ExerciseEntity currentEx) {
    // 1. Nếu là bài giữ thế (Plank) có thời gian durationSeconds > 0
    if (currentEx.duration.inSeconds > 0) {
      final double progress = _holdTimeRemaining / currentEx.duration.inSeconds;
      return Column(
        children: [
          SizedBox(
            width: 160, height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: VitaTrackTheme.mauCard,
                  color: VitaTrackTheme.mauThanhCong,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${_holdTimeRemaining}s',
                  style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 36, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isHoldActive && _holdTimeRemaining > 0)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: VitaTrackTheme.mauThanhCong),
                  onPressed: _startHoldTimer,
                  icon: const Icon(Icons.play_arrow, color: VitaTrackTheme.mauNen),
                  label: const Text('BẮT ĐẦU GIỮ THẾ', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold)),
                )
              else if (_isHoldActive)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: VitaTrackTheme.mauCanhBao),
                  onPressed: _pauseHoldTimer,
                  icon: const Icon(Icons.pause, color: VitaTrackTheme.mauNen),
                  label: const Text('TẠM DỪNG', style: TextStyle(color: VitaTrackTheme.mauNen, fontWeight: FontWeight.bold)),
                )
              else
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: VitaTrackTheme.mauThanhCong),
                    SizedBox(width: 6),
                    Text('Đã giữ thế thành công!', style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          )
        ],
      );
    }

    // 2. Bài tập tính reps
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, '${_accumulatedCalories.toStringAsFixed(1)}', 'CALO ĐÃ ĐỐT'),
        Container(width: 1, height: 60, color: VitaTrackTheme.mauCardNhat),
        _stat(Icons.fitness_center, VitaTrackTheme.mauThanhCong, '${currentEx.reps}', 'MỤC TIÊU CÁI'),
      ],
    );
  }

  // Màn hình đếm ngược thời gian nghỉ (Rest Screen)
  Widget _buildRestScreen() {
    final currentEx = widget.exercises[_currentExerciseIndex];
    final nextEx = (_currentSetIndex < currentEx.sets) ? currentEx : ((_currentExerciseIndex < widget.exercises.length - 1) ? widget.exercises[_currentExerciseIndex + 1] : null);

    return Container(
      width: double.infinity,
      color: const Color(0xFF14221D), // Tone xanh rêu đậm phục hồi
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.spa, color: VitaTrackTheme.mauThanhCong, size: 64),
          const SizedBox(height: 16),
          const Text(
            'HÍT SÂU - THỞ ĐỀU',
            style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nghỉ ngơi hồi sức',
            style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14),
          ),
          const SizedBox(height: 32),
          
          // Vòng tròn đếm ngược
          SizedBox(
            width: 140, height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _restTimeRemaining / currentEx.restSeconds,
                  color: VitaTrackTheme.mauThanhCong,
                  backgroundColor: VitaTrackTheme.mauCard,
                  strokeWidth: 8,
                ),
                Text(
                  '${_restTimeRemaining}s',
                  style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          if (nextEx != null) ...[
            const Text(
              'BÀI TIẾP THEO:',
              style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 11, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              nextEx.name,
              style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              (_currentSetIndex < currentEx.sets) 
                  ? 'Hiệp ${_currentSetIndex + 1} / ${currentEx.sets}'
                  : 'Hiệp 1 / ${nextEx.sets} (${nextEx.reps > 0 ? "${nextEx.reps} cái" : "${nextEx.duration.inSeconds}s giữ"})',
              style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 13),
            ),
          ],

          const SizedBox(height: 60),

          // Nút bỏ qua nghỉ
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: VitaTrackTheme.mauThanhCong, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _skipRest,
            child: const Text(
              'TẬP TIẾP LUÔN',
              style: TextStyle(color: VitaTrackTheme.mauThanhCong, fontWeight: FontWeight.bold),
            ),
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
                  width: 100, height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircularProgressIndicator(value: 1.0, strokeWidth: 6, color: VitaTrackTheme.mauCard),
                      CircularProgressIndicator(value: _holdController.value, strokeWidth: 8, backgroundColor: Colors.transparent, color: VitaTrackTheme.mauNguyHiem, strokeCap: StrokeCap.round),
                      Container(width: 70, height: 70, decoration: BoxDecoration(color: VitaTrackTheme.mauNguyHiem, shape: BoxShape.circle), child: const Icon(Icons.stop_rounded, color: VitaTrackTheme.mauNen, size: 36)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(opacity: _holdController.value > 0 ? 0.0 : 1.0, duration: const Duration(milliseconds: 200), child: const Text('Nhấn giữ để kết thúc', style: TextStyle(color: VitaTrackTheme.mauChuPhu))),
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
