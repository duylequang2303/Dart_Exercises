import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/health_metric.dart';
import '../../data/datasources/pedometer_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthNotifier extends StateNotifier<HealthMetric> {
  final PedometerDatasource _pedometer;

  HealthNotifier(this._pedometer)
      : super(const HealthMetric(steps: 0, sleepHours: 7.5)) {
    
    _loadInitialData();

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

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDate = prefs.getString('sleep_hours_date');
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      
      if (lastDate != todayStr) {
        // Reset or require new input if it's a new day, but for now just use default or 0
        // the prompt says: "use default 7.5 if not set" and "reset at midnight".
        // Actually, let's set it to 0.0 or 7.5? Wait, prompt: "default 7.5 if not set". 
        // If it resets, maybe it should just stay 7.5, or the user enters it.
        // Let's just default to 7.5.
        await prefs.setDouble('sleep_hours_last_night', 7.5);
        await prefs.setString('sleep_hours_date', todayStr);
        state = state.copyWith(sleepHours: 7.5);
      } else {
        final hours = prefs.getDouble('sleep_hours_last_night') ?? 7.5;
        state = state.copyWith(sleepHours: hours);
      }
    } catch (e) {
      debugPrint("Error loading sleep hours: $e");
    }
  }

  Future<void> updateSleepHours(double hours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      await prefs.setDouble('sleep_hours_last_night', hours);
      await prefs.setString('sleep_hours_date', todayStr);
      state = state.copyWith(sleepHours: hours);
    } catch (e) {
      debugPrint("Error saving sleep hours: $e");
    }
  }

  @override
  void dispose() {
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
