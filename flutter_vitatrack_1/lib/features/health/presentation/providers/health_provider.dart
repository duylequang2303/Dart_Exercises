import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/services/mock_data_service.dart';

import '../../domain/entities/health_metric.dart';
import '../../data/health_repository.dart';

/// A simple StateNotifier that keeps the latest HealthMetric and updates when
/// the MockDataService notifies listeners.
class HealthNotifier extends StateNotifier<HealthMetric> {
  final HealthRepository _repo;
  final MockDataService _svc;
  late final void Function() _listener;

  HealthNotifier(this._repo, this._svc)
      : super(const HealthMetric(steps: 0, heartRate: 0, sleepHours: 0.0)) {
    _listener = () {
      _refresh();
    };
    _svc.addListener(_listener);
    _refresh();
  }

  Future<void> _refresh() async {
    final metric = await _repo.fetchLatest();
    state = metric;
  }

  @override
  void dispose() {
    try {
      _svc.removeListener(_listener);
    } catch (_) {}
    super.dispose();
  }
}

final healthProvider = StateNotifierProvider<HealthNotifier, HealthMetric>((ref) {
  final svc = MockDataService.instance;
  final repo = HealthRepository(service: svc);
  return HealthNotifier(repo, svc);
});
