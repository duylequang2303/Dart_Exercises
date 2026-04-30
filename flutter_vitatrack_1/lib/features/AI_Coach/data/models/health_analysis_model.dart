import '../../domain/entities/health_analysis.dart';

class HealthAnalysisModel extends HealthAnalysis {
  const HealthAnalysisModel({
    required super.summary,
    required super.sleepQualityChange,
    required super.waterIntake,
    required super.waterRemaining,
    required super.caloriesBurned,
    required super.caloriesGoalPercent,
    required super.weeklyActivity,
  });

  /// Parse JSON từ Groq API response
  factory HealthAnalysisModel.fromJson(Map<String, dynamic> json) {
    final rawActivity = json['weeklyActivity'] as Map<String, dynamic>? ?? {};
    final weeklyActivity = rawActivity.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );

    return HealthAnalysisModel(
      summary: json['summary'] as String? ?? '',
      sleepQualityChange: (json['sleepQualityChange'] as num?)?.toInt() ?? 0,
      waterIntake: (json['waterIntake'] as num?)?.toDouble() ?? 0.0,
      waterRemaining: (json['waterRemaining'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt() ?? 0,
      caloriesGoalPercent: (json['caloriesGoalPercent'] as num?)?.toInt() ?? 0,
      weeklyActivity: weeklyActivity,
    );
  }

  /// Fallback khi parse JSON thất bại - dùng data từ context
  factory HealthAnalysisModel.fallback({
    required String summaryText,
    required int caloriesBurned,
    required double waterIntake,
    required double waterRemaining,
  }) {
    return HealthAnalysisModel(
      summary: summaryText,
      sleepQualityChange: 0,
      waterIntake: waterIntake,
      waterRemaining: waterRemaining,
      caloriesBurned: caloriesBurned,
      caloriesGoalPercent: 0,
      weeklyActivity: const {},
    );
  }
}