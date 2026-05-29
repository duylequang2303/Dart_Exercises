class HealthMetric {
  final int steps;
  final int heartRate;
  final double sleepHours;

  const HealthMetric({required this.steps, required this.heartRate, required this.sleepHours});

  factory HealthMetric.fromMap(Map<String, dynamic> map) => HealthMetric(
        steps: map['steps'] as int? ?? 0,
        heartRate: map['heartRate'] as int? ?? 0,
        sleepHours: (map['sleepHours'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toMap() => {
        'steps': steps,
        'heartRate': heartRate,
        'sleepHours': sleepHours,
      };

  HealthMetric copyWith({int? steps, int? heartRate, double? sleepHours}) {
    return HealthMetric(
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      sleepHours: sleepHours ?? this.sleepHours,
    );
  }
}
