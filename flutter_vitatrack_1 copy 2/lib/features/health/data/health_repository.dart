import 'package:flutter_vitatrack_1/services/mock_data_service.dart';

import '../domain/entities/health_metric.dart';

/// Simple repository that reads latest health values from MockDataService.
class HealthRepository {
  final MockDataService _svc;

  HealthRepository({MockDataService? service}) : _svc = service ?? MockDataService.instance;

  /// Fetch the latest health metrics from the mock service.
  Future<HealthMetric> fetchLatest() async {
    final steps = _svc.steps;
    final heartRate = _svc.heartRate;
    // MockDataService does not expose sleep data in this project; default to 0.0
    final sleepHours = 0.0;

    return HealthMetric(steps: steps, heartRate: heartRate, sleepHours: sleepHours);
  }
}
