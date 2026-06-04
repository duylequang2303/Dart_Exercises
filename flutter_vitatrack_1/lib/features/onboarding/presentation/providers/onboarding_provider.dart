import 'package:riverpod/riverpod.dart';

class OnboardingState {
  final int currentPage;
  final bool isCalculating;
  final String goal;
  final String gender;
  final double height;
  final double weight;
  final int age;
  final String intensity;

  // Kết quả tính toán thực từ công thức
  final int caloriesGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const OnboardingState({
    this.currentPage = 0,
    this.isCalculating = false,
    this.goal = 'Giảm cân',
    this.gender = 'Nam',
    this.height = 170,
    this.weight = 65,
    this.age = 25,
    this.intensity = 'Vừa phải',
    this.caloriesGoal = 0,
    this.proteinGoal = 0,
    this.carbsGoal = 0,
    this.fatGoal = 0,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isCalculating,
    String? goal,
    String? gender,
    double? height,
    double? weight,
    int? age,
    String? intensity,
    int? caloriesGoal,
    int? proteinGoal,
    int? carbsGoal,
    int? fatGoal,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCalculating: isCalculating ?? this.isCalculating,
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      intensity: intensity ?? this.intensity,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setCurrentPage(int page) => state = state.copyWith(currentPage: page);
  void setGoal(String goal) => state = state.copyWith(goal: goal);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setHeight(double height) => state = state.copyWith(height: height);
  void setWeight(double weight) => state = state.copyWith(weight: weight);
  void setAge(int age) => state = state.copyWith(age: age);
  void setIntensity(String intensity) => state = state.copyWith(intensity: intensity);

  /// Tính toán thực dựa trên Mifflin-St Jeor + macro split
  Future<void> calculateAndShowResult() async {
    state = state.copyWith(isCalculating: true);

    // Giả lập thời gian "AI đang tính"
    await Future.delayed(const Duration(seconds: 2));

    final h = state.height;
    final w = state.weight;
    final age = state.age;
    final bool isNam = state.gender == 'Nam';

    // BMR - Mifflin-St Jeor
    final bmr = isNam
        ? (10 * w + 6.25 * h - 5 * age + 5)
        : (10 * w + 6.25 * h - 5 * age - 161);

    // Hệ số hoạt động
    final actFactor = switch (state.intensity) {
      'Ít vận động'   => 1.2,
      'Vừa phải'      => 1.375,
      'Năng động'     => 1.55,
      'Vận động viên' => 1.725,
      _               => 1.375,
    };

    final tdee = bmr * actFactor;

    // Điều chỉnh theo mục tiêu
    final calories = switch (state.goal) {
      'Giảm cân' => (tdee - 500).toInt(),
      'Tăng cơ'  => (tdee + 300).toInt(),
      _          => tdee.toInt(), // Giữ dáng
    };

    // Macro split (protein cao hơn khi tăng cơ/giảm cân)
    final int protein;
    final int carbs;
    final int fat;

    switch (state.goal) {
      case 'Giảm cân':
        // 35% protein, 40% carbs, 25% fat
        protein = (calories * 0.35 / 4).round();
        carbs    = (calories * 0.40 / 4).round();
        fat      = (calories * 0.25 / 9).round();
        break;
      case 'Tăng cơ':
        // 30% protein, 50% carbs, 20% fat
        protein = (calories * 0.30 / 4).round();
        carbs    = (calories * 0.50 / 4).round();
        fat      = (calories * 0.20 / 9).round();
        break;
      default: // Giữ dáng
        // 25% protein, 50% carbs, 25% fat
        protein = (calories * 0.25 / 4).round();
        carbs    = (calories * 0.50 / 4).round();
        fat      = (calories * 0.25 / 9).round();
    }

    state = state.copyWith(
      isCalculating: false,
      caloriesGoal: calories,
      proteinGoal: protein,
      carbsGoal: carbs,
      fatGoal: fat,
    );
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);