import 'package:riverpod/riverpod.dart';

class OnboardingState {
  final int currentPage;
  final bool isCalculating;
  final String goal;
  final String gender;
  final double height;
  final double weight;
  final String intensity;

  const OnboardingState({
    this.currentPage = 0,
    this.isCalculating = false,
    this.goal = 'Giảm cân',
    this.gender = 'Nam',
    this.height = 170,
    this.weight = 65,
    this.intensity = 'Vừa phải',
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isCalculating,
    String? goal,
    String? gender,
    double? height,
    double? weight,
    String? intensity,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCalculating: isCalculating ?? this.isCalculating,
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      intensity: intensity ?? this.intensity,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setHeight(double height) {
    state = state.copyWith(height: height);
  }

  void setWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void setIntensity(String intensity) {
    state = state.copyWith(intensity: intensity);
  }

  Future<void> simulateAICalculation() async {
    state = state.copyWith(isCalculating: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isCalculating: false);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
