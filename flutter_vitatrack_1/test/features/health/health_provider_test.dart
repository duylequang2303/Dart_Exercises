import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/health/data/datasources/pedometer_datasource.dart';
import 'package:flutter_vitatrack_1/features/health/presentation/providers/health_provider.dart';

class FakePedometerDatasource extends PedometerDatasource {
  Function(int)? _onStepCountUpdate;
  Function(dynamic)? _onError;

  @override
  Future<bool> requestPermission() async => true;

  @override
  void startListening(Function(int) onStepCountUpdate, Function(dynamic) onError) {
    _onStepCountUpdate = onStepCountUpdate;
    _onError = onError;
  }

  @override
  void stopListening() {
    _onStepCountUpdate = null;
    _onError = null;
  }

  void emitSteps(int steps) {
    _onStepCountUpdate?.call(steps);
  }

  void emitError(dynamic error) {
    _onError?.call(error);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakePedometerDatasource fakePedometer;
  late ProviderContainer container;

  setUp(() {
    fakePedometer = FakePedometerDatasource();
    container = ProviderContainer(
      overrides: [
        pedometerDatasourceProvider.overrideWithValue(fakePedometer),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Khởi tạo HealthNotifier với thông số mặc định', () {
    // Đọc provider trước để khởi tạo notifier
    final healthMetric = container.read(healthProvider);
    expect(healthMetric.steps, 0);
    expect(healthMetric.sleepHours, 7.5);
  });

  test('Nhận sự kiện đếm bước từ cảm biến và cập nhật state', () async {
    // Đọc notifier để nó đăng ký lắng nghe cảm biến
    final notifier = container.read(healthProvider.notifier);
    await Future.delayed(Duration.zero);

    // Phát số bước mới từ cảm biến giả lập
    fakePedometer.emitSteps(1000);
    expect(container.read(healthProvider).steps, 1000);

    fakePedometer.emitSteps(2500);
    expect(container.read(healthProvider).steps, 2500);
  });


}
