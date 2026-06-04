class HealthMetric {
  final int steps;
  final double sleepHours;

  const HealthMetric({required this.steps, required this.sleepHours});

  factory HealthMetric.fromMap(Map<String, dynamic> map) => HealthMetric(
        steps: map['steps'] as int? ?? 0,
        sleepHours: (map['sleepHours'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toMap() => {
        'steps': steps,
        'sleepHours': sleepHours,
      };

  HealthMetric copyWith({int? steps, double? sleepHours}) {
    return HealthMetric(
      steps: steps ?? this.steps,
      sleepHours: sleepHours ?? this.sleepHours,
    );
  }
}
