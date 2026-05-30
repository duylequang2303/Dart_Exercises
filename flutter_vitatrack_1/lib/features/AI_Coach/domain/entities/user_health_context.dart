/// Entity chứa toàn bộ dữ liệu sức khỏe của user
/// để truyền vào AI làm context
class UserHealthContext {
  // ─── Từ Health ───────────────────────────────
  final int stepsToday;
  final int dailyStepsGoal;
  final int heartRateBpm;
  final double sleepHours;

  // ─── Từ Nutrition ────────────────────────────
  final int caloriesBurned;
  final int dailyCaloriesGoal;
  final int waterIntakeMl;
  final int dailyWaterGoalMl;
  final double proteinGram;
  final double carbsGram;
  final double fatGram;

  // ─── Từ Profile ──────────────────────────────
  final int? tuoi;
  final double? chieuCao;
  final double? canNang;
  final String? gioiTinh;
  final String? mucTieu;
  final String? cuongDo;

  const UserHealthContext({
    required this.stepsToday,
    required this.dailyStepsGoal,
    required this.heartRateBpm,
    required this.sleepHours,
    required this.caloriesBurned,
    required this.dailyCaloriesGoal,
    required this.waterIntakeMl,
    required this.dailyWaterGoalMl,
    this.proteinGram = 0,
    this.carbsGram = 0,
    this.fatGram = 0,
    this.tuoi,
    this.chieuCao,
    this.canNang,
    this.gioiTinh,
    this.mucTieu,
    this.cuongDo,
  });

  /// Tính BMI từ chiều cao và cân nặng
  double? get bmi {
    if (chieuCao == null || canNang == null) return null;
    if (chieuCao! <= 0) return null;
    final heightM = chieuCao! / 100;
    return canNang! / (heightM * heightM);
  }

  /// Đánh giá BMI
  String get bmiCategory {
    final b = bmi;
    if (b == null) return 'Chưa có dữ liệu';
    if (b < 18.5) return 'Thiếu cân';
    if (b < 25.0) return 'Bình thường';
    if (b < 30.0) return 'Thừa cân';
    return 'Béo phì';
  }

  /// Chuyển thành chuỗi để đưa vào prompt AI
  String toPromptContext() {
    final bmiText = bmi != null
        ? '${bmi!.toStringAsFixed(1)} ($bmiCategory)'
        : 'Chưa có dữ liệu';

    return '''
THÔNG TIN CÁ NHÂN:
- Tuổi: ${tuoi ?? 'Chưa có'}
- Giới tính: ${gioiTinh ?? 'Chưa có'}
- Chiều cao: ${chieuCao != null ? '${chieuCao}cm' : 'Chưa có'}
- Cân nặng: ${canNang != null ? '${canNang}kg' : 'Chưa có'}
- BMI: $bmiText
- Mục tiêu: ${mucTieu ?? 'Chưa có'}
- Cường độ tập: ${cuongDo ?? 'Chưa có'}

SỨC KHỎE HÔM NAY:
- Số bước: $stepsToday/$dailyStepsGoal bước
- Nhịp tim: $heartRateBpm BPM
- Giấc ngủ: $sleepHours giờ

DINH DƯỠNG HÔM NAY:
- Calories: $caloriesBurned/$dailyCaloriesGoal kcal
- Nước uống: ${waterIntakeMl}ml/${dailyWaterGoalMl}ml
- Protein: ${proteinGram}g
- Carbs: ${carbsGram}g
- Chất béo: ${fatGram}g
''';
  }
}