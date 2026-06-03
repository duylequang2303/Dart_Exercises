class UserHealthContext {
  final int stepsToday;
  final int caloriesBurned;
  final int activeCaloriesBurned;
  final int waterIntakeMl;
  final double sleepHours;
  final int heartRateBpm;
  final int dailyStepsGoal;
  final int dailyCaloriesGoal;
  final int dailyWaterGoalMl;

  // Thông tin profile từ onboarding
  final String? mucTieu;   // Giảm cân / Giữ dáng / Tăng cơ
  final String? gioiTinh;  // Nam / Nữ
  final double? chieuCao;  // cm
  final double? canNang;   // kg
  final String? cuongDo;   // Ít vận động / Vừa phải / Năng động / Vận động viên
  final int? tuoi;         // tuổi

  // Macro dinh dưỡng hôm nay
  final double proteinGram;
  final double carbsGram;
  final double fatGram;

  // Chi tiết ăn uống và tập luyện
  final List<String> mealNames;
  final List<String> workoutNames;

  const UserHealthContext({
    required this.stepsToday,
    required this.caloriesBurned,
    this.activeCaloriesBurned = 0,
    required this.waterIntakeMl,
    required this.sleepHours,
    required this.heartRateBpm,
    required this.dailyStepsGoal,
    required this.dailyCaloriesGoal,
    required this.dailyWaterGoalMl,
    this.mucTieu,
    this.gioiTinh,
    this.chieuCao,
    this.canNang,
    this.cuongDo,
    this.tuoi,
    this.proteinGram = 0,
    this.carbsGram = 0,
    this.fatGram = 0,
    this.mealNames = const [],
    this.workoutNames = const [],
  });

  // ── Computed getters ──────────────────────────────────────

  double? get bmi {
    if (chieuCao == null || canNang == null) return null;
    final h = chieuCao! / 100;
    return canNang! / (h * h);
  }

  String get bmiCategory {
    final b = bmi;
    if (b == null) return 'Chưa có dữ liệu';
    if (b < 18.5) return 'Thiếu cân';
    if (b < 25.0) return 'Bình thường';
    if (b < 30.0) return 'Thừa cân';
    return 'Béo phì';
  }

  // ── Prompt cho AI ─────────────────────────────────────────

  String toPromptContext() {
    final profileInfo = StringBuffer();

    if (gioiTinh != null || canNang != null || chieuCao != null) {
      profileInfo.writeln('\nThông tin cá nhân:');
      if (gioiTinh != null) profileInfo.writeln('- Giới tính: $gioiTinh');
      if (tuoi != null) profileInfo.writeln('- Tuổi: $tuoi');
      if (chieuCao != null) profileInfo.writeln('- Chiều cao: ${chieuCao!.toInt()} cm');
      if (canNang != null) profileInfo.writeln('- Cân nặng: ${canNang!.toInt()} kg');
      if (bmi != null) profileInfo.writeln('- BMI: ${bmi!.toStringAsFixed(1)} ($bmiCategory)');
    }

    if (mucTieu != null) profileInfo.writeln('- Mục tiêu: $mucTieu');
    if (cuongDo != null) profileInfo.writeln('- Mức độ vận động: $cuongDo');

    return '''
${profileInfo.toString()}
Dữ liệu sức khỏe hôm nay:
- Số bước: $stepsToday/$dailyStepsGoal bước
- Calories nạp vào (Ăn uống): $caloriesBurned/$dailyCaloriesGoal kcal
- Calories tiêu hao (Tập luyện): $activeCaloriesBurned kcal
- Protein: ${proteinGram.toStringAsFixed(0)}g | Carbs: ${carbsGram.toStringAsFixed(0)}g | Chất béo: ${fatGram.toStringAsFixed(0)}g
- Nước uống: ${waterIntakeMl}ml/${dailyWaterGoalMl}ml
- Giấc ngủ: $sleepHours giờ
- Nhịp tim trung bình: $heartRateBpm BPM

Chi tiết hoạt động hôm nay:
- Các món đã ăn: ${mealNames.isEmpty ? 'Chưa ăn gì' : mealNames.join(', ')}
- Các bài đã tập: ${workoutNames.isEmpty ? 'Chưa tập gì' : workoutNames.join(', ')}
''';
  }
}