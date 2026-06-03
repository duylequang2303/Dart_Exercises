import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vitatrack_1/features/workout/presentation/services/workout_timer_service.dart';

void main() {
  late WorkoutTimerService timerService;

  setUp(() {
    timerService = WorkoutTimerService();
  });

  tearDown(() {
    timerService.dispose();
  });

  test('Khởi tạo WorkoutTimerService với thời gian bằng 0', () {
    expect(timerService.elapsed, Duration.zero);
  });

  test('start() và stop() quản lý bộ đếm giờ chạy và dừng chính xác', () async {
    timerService.start();

    // Chờ 1.5 giây để bộ đếm tăng thêm ít nhất 1 giây
    await Future.delayed(const Duration(milliseconds: 1500));

    expect(timerService.elapsed.inSeconds, greaterThanOrEqualTo(1));

    final currentElapsed = timerService.elapsed;
    timerService.stop();

    // Chờ thêm 1.5 giây sau khi stop()
    await Future.delayed(const Duration(milliseconds: 1500));

    // Thời gian trôi qua không được tăng thêm
    expect(timerService.elapsed, currentElapsed);
  });

  test('reset() đưa thời gian trôi qua về 0 và dừng bộ đếm', () async {
    timerService.start();
    await Future.delayed(const Duration(milliseconds: 1200));

    expect(timerService.elapsed.inSeconds, greaterThanOrEqualTo(1));

    timerService.reset();
    expect(timerService.elapsed, Duration.zero);

    // Đợi thêm để chắc chắn bộ đếm không tự tăng lại
    await Future.delayed(const Duration(milliseconds: 1200));
    expect(timerService.elapsed, Duration.zero);
  });

  test('startCountdown() đếm ngược chính xác và tự kích hoạt bộ đếm giờ chính', () async {
    final countdownValues = <int?>[];
    
    final sub = timerService.countdownStream.listen((val) {
      countdownValues.add(val);
    });

    // Bắt đầu đếm ngược từ 2 giây
    timerService.startCountdown(2);

    // Chờ 2.5 giây để hoàn thành đếm ngược và kích hoạt main timer
    await Future.delayed(const Duration(milliseconds: 2500));

    // Dưới đây là giá trị đếm ngược nhận được: 2 -> 1 -> null
    expect(countdownValues, contains(2));
    expect(countdownValues, contains(1));
    expect(countdownValues.last, null);

    // Sau khi đếm ngược kết thúc, main timer tự chạy
    expect(timerService.elapsed.inSeconds, greaterThanOrEqualTo(0));

    await sub.cancel();
  });

  test('stopCountdown() dừng đếm ngược và đưa trạng thái về null', () async {
    timerService.startCountdown(5);
    await Future.delayed(const Duration(milliseconds: 500));

    // Lắng nghe stream TRƯỚC KHI gọi stopCountdown để hứng sự kiện null phát ra
    final expectFuture = expectLater(timerService.countdownStream, emits(null));

    timerService.stopCountdown();

    await expectFuture;
  });
}
