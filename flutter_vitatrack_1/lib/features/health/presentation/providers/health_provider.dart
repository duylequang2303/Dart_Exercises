import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_metric.dart';
import '../../data/datasources/pedometer_datasource.dart';

class HealthNotifier extends StateNotifier<HealthMetric> {
  final PedometerDatasource _pedometer;
  Timer? _heartRateTimer;
  final Random _random = Random();

  HealthNotifier(this._pedometer)
      : super(const HealthMetric(steps: 0, heartRate: 72, sleepHours: 7.5)) {
    
    // Không giả lập nhịp tim ngẫu nhiên nữa vì người dùng đánh giá là vô ích (phế)
    // _heartRateTimer = Timer.periodic(...)

    // Lắng nghe dữ liệu THẬT từ cảm biến đếm bước
    _pedometer.startListening(
      (steps) {
        state = state.copyWith(steps: steps);
      },
      (error) {
        debugPrint("HealthNotifier Error: $error");
      }
    );
  }

  @override
  void dispose() {
    _heartRateTimer?.cancel();
    _pedometer.stopListening();
    super.dispose();
  }
}

final pedometerDatasourceProvider = Provider<PedometerDatasource>((ref) {
  return PedometerDatasource();
});

final healthProvider = StateNotifierProvider<HealthNotifier, HealthMetric>((ref) {
  final pedometer = ref.watch(pedometerDatasourceProvider);
  return HealthNotifier(pedometer);
});
