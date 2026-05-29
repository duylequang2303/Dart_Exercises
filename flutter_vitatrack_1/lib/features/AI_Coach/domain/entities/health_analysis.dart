class HealthAnalysis {
  final String summary;
  final List<String> diemTot;
  final List<String> canCaiThien;
  final String bmiDanhGia;
  final int sleepQualityChange;
  final double waterIntake;
  final double waterRemaining;
  final int caloriesBurned;
  final int caloriesGoalPercent;
  final Map<String, int> weeklyActivity;

  const HealthAnalysis({
    required this.summary,
    required this.diemTot,
    required this.canCaiThien,
    required this.bmiDanhGia,
    required this.sleepQualityChange,
    required this.waterIntake,
    required this.waterRemaining,
    required this.caloriesBurned,
    required this.caloriesGoalPercent,
    required this.weeklyActivity,
  });
}