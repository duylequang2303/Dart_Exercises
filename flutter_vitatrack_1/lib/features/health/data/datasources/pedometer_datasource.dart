import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PedometerDatasource {
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;

  /// Yêu cầu quyền truy cập cảm biến chuyển động
  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      return true;
    } else {
      debugPrint("Quyền truy cập cảm biến đếm bước bị từ chối.");
      return false;
    }
  }

  /// Lắng nghe stream bước chân real-time
  void startListening(Function(int) onStepCountUpdate, Function(dynamic) onError) async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      onError(Exception("Không có quyền truy cập cảm biến đếm bước."));
      return;
    }

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountSubscription = _stepCountStream?.listen(
        (StepCount event) {
          debugPrint("Pedometer update: ${event.steps}");
          onStepCountUpdate(event.steps);
        },
        onError: (error) {
          debugPrint("Lỗi đọc cảm biến Pedometer: $error");
          onError(error);
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("Lỗi khởi tạo Pedometer: $e");
      onError(e);
    }
  }

  void stopListening() {
    _stepCountSubscription?.cancel();
  }
}
