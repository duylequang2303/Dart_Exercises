class UserHealthContext {
  final int stepsToday;
  final int caloriesBurned;
  final int waterIntakeMl;
  final double sleepHours;
  final int heartRateBpm;
  final int dailyStepsGoal;
  final int dailyCaloriesGoal;
  final int dailyWaterGoalMl;

  const UserHealthContext({
    required this.stepsToday,
    required this.caloriesBurned,
    required this.waterIntakeMl,
    required this.sleepHours,
    required this.heartRateBpm,
    required this.dailyStepsGoal,
    required this.dailyCaloriesGoal,
    required this.dailyWaterGoalMl,
  });

  // Chuyển thành chuỗi để đưa vào prompt AI
  String toPromptContext() {
    return '''
Dữ liệu sức khỏe hôm nay của người dùng:
- Số bước: $stepsToday/$dailyStepsGoal bước
- Calories đốt cháy: $caloriesBurned/$dailyCaloriesGoal kcal
- Nước uống: ${waterIntakeMl}ml/${dailyWaterGoalMl}ml
- Giấc ngủ: $sleepHours giờ
- Nhịp tim trung bình: $heartRateBpm BPM
''';
  }
}