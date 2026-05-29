import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/services/mock_data_service.dart';
import '../../domain/entities/health_metric.dart';
import '../../data/datasources/pedometer_datasource.dart';

class HealthNotifier extends StateNotifier<HealthMetric> {
  final PedometerDatasource _pedometer;
  final MockDataService _mockSvc;
  late final void Function() _mockListener;

  HealthNotifier(this._pedometer, this._mockSvc)
      : super(const HealthMetric(steps: 0, heartRate: 0, sleepHours: 0.0)) {
    
    // Vẫn dùng MockData cho nhịp tim vì Pedometer chỉ đếm bước
    _mockListener = () {
      state = state.copyWith(heartRate: _mockSvc.heartRate);
    };
    _mockSvc.addListener(_mockListener);
    state = state.copyWith(heartRate: _mockSvc.heartRate);

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
    _mockSvc.removeListener(_mockListener);
    _pedometer.stopListening();
    super.dispose();
  }
}

final pedometerDatasourceProvider = Provider<PedometerDatasource>((ref) {
  return PedometerDatasource();
});

final healthProvider = StateNotifierProvider<HealthNotifier, HealthMetric>((ref) {
  final pedometer = ref.watch(pedometerDatasourceProvider);
  final mockSvc = MockDataService.instance;
  return HealthNotifier(pedometer, mockSvc);
});
