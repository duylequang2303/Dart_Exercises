import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/core/theme.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/providers/workout_timer_provider.dart';

class LiveWorkoutScreen extends ConsumerStatefulWidget {
  final String tenBaiTap;
  final IconData iconBaiTap;

  const LiveWorkoutScreen({super.key, required this.tenBaiTap, required this.iconBaiTap});

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
    // Delegate countdown to service
    // start countdown via the notifier -> service will start main timer when countdown ends
    ref.read(workoutElapsedProvider.notifier).reset();
    ref.read(workoutElapsedProvider.notifier).startCountdown(3);
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _endWorkout() {
    if (_ended) return;
    _ended = true;
    ref.read(workoutElapsedProvider.notifier).stop();
    HapticFeedback.heavyImpact();
    Future.microtask(() {
      if (mounted) Navigator.pop(context, true);
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = ref.watch(workoutElapsedProvider);
    final calo = (elapsed.inSeconds * 0.15);
    final hr = 100 + (elapsed.inSeconds % 30);

    final countdownAsync = ref.watch(workoutCountdownProvider);
    int? countdown = countdownAsync.when(data: (v) => v, loading: () => null, error: (_, __) => null);

    return Scaffold(
      backgroundColor: VitaTrackTheme.mauNen,
      body: SafeArea(
        child: countdown != null ? _buildCountdown(countdown) : _buildLive(elapsed, calo, hr),
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

  Widget _buildLive(Duration elapsed, double calo, int hr) {
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
              const Text('THỜI GIAN', style: TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 14, letterSpacing: 2)),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _stat(Icons.local_fire_department, VitaTrackTheme.mauNguyHiem, calo.toStringAsFixed(1), 'KCAL'),
                  Container(width: 1, height: 50, color: VitaTrackTheme.mauCardNhat),
                  _stat(Icons.favorite, VitaTrackTheme.mauNguyHiem, '$hr', 'BPM', isHeart: true),
                ],
              )
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

  Widget _stat(IconData icon, Color color, String value, String unit, {bool isHeart = false}) {
    return Column(
      children: [
        isHeart
? TweenAnimationBuilder<double>(
            key: ValueKey(value),
            tween: Tween<double>(begin: 1.2, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, scale, child) => Transform.scale(scale: scale, child: Icon(icon, color: color, size: 28)),
          )
        : Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: VitaTrackTheme.mauChu, fontSize: 36, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(color: VitaTrackTheme.mauChuPhu, fontSize: 12, letterSpacing: 1)),
      ],
    );
  }
}
