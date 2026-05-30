import '../../domain/entities/health_analysis.dart';

class HealthAnalysisModel extends HealthAnalysis {
  const HealthAnalysisModel({
    required super.summary,
    required super.diemTot,
    required super.canCaiThien,
    required super.bmiDanhGia,
    required super.sleepQualityChange,
    required super.waterIntake,
    required super.waterRemaining,
    required super.caloriesBurned,
    required super.caloriesGoalPercent,
    required super.weeklyActivity,
  });

  factory HealthAnalysisModel.fromJson(Map<String, dynamic> json) {
    final rawActivity = json['weeklyActivity'] as Map<String, dynamic>? ?? {};
    final weeklyActivity = rawActivity.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );

    final diemTotRaw = json['diemTot'] as List<dynamic>? ?? [];
    final diemTot = diemTotRaw.map((e) => e.toString()).toList();

    final canCaiThienRaw = json['canCaiThien'] as List<dynamic>? ?? [];
    final canCaiThien = canCaiThienRaw.map((e) => e.toString()).toList();

    return HealthAnalysisModel(
      summary: json['summary'] as String? ?? '',
      diemTot: diemTot,
      canCaiThien: canCaiThien,
      bmiDanhGia: json['bmiDanhGia'] as String? ?? '',
      sleepQualityChange: (json['sleepQualityChange'] as num?)?.toInt() ?? 0,
      waterIntake: (json['waterIntake'] as num?)?.toDouble() ?? 0.0,
      waterRemaining: (json['waterRemaining'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt() ?? 0,
      caloriesGoalPercent: (json['caloriesGoalPercent'] as num?)?.toInt() ?? 0,
      weeklyActivity: weeklyActivity,
    );
  }

  factory HealthAnalysisModel.fallback({
    required String summaryText,
    required int caloriesBurned,
    required double waterIntake,
    required double waterRemaining,
  }) {
    return HealthAnalysisModel(
      summary: summaryText,
      diemTot: const [],
      canCaiThien: const [],
      bmiDanhGia: '',
      sleepQualityChange: 0,
      waterIntake: waterIntake,
      waterRemaining: waterRemaining,
      caloriesBurned: caloriesBurned,
      caloriesGoalPercent: 0,
      weeklyActivity: const {},
    );
  }
}