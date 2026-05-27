// lib/features/workout/presentation/screens/live_workout_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_timer_provider.dart';

class LiveWorkoutScreen extends ConsumerStatefulWidget {
  final String exId;
  final String exName;

  const LiveWorkoutScreen({super.key, required this.exId, required this.exName});

  @override
  ConsumerState<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends ConsumerState<LiveWorkoutScreen> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Kích hoạt bộ đếm giờ của Việc 4 ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutTimerProvider.notifier).startTracking();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Đảm bảo khi mở lại máy lên từ chế độ tắt/Background, timer lập tức kéo dữ liệu chuẩn xác
    if (state == AppLifecycleState.resumed) {
      ref.read(workoutTimerProvider.notifier).forceSyncFromBackground();
    }
  }

  String _formatTime(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(workoutTimerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      appBar: AppBar(
        title: Text(widget.exName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('THỜI GIAN TẬP THỰC TẾ', style: TextStyle(color: Colors.grey, letterSpacing: 1.5)),
                    const SizedBox(height: 20),
                    // Neon Circular Progress Gradient Indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: (timerState.seconds % 60) / 60,
                            strokeWidth: 8,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        Text(
                          _formatTime(timerState.seconds),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.cyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(backgroundColor: timerState.isRunning ? Colors.amber : Colors.cyan),
                          onPressed: () {
                            if (timerState.isRunning) {
                              ref.read(workoutTimerProvider.notifier).pauseTracking();
                            } else {
                              ref.read(workoutTimerProvider.notifier).startTracking();
                            }
                          },
                          icon: Icon(timerState.isRunning ? Icons.pause : Icons.play_arrow, color: Colors.black),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            // Gọi UseCase lưu Firestore ở đây khi kết thúc
                            ref.read(workoutTimerProvider.notifier).resetTracking();
                            Navigator.pop(context);
                          },
                          child: const Text('HOÀN THÀNH', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}