
/// Domain entity representing a single Exercise.
class ExerciseEntity {
  final String id;
  final String name;
  final String? instructions;
  final int sets;
  final int reps;
  final Duration duration;
  final int restSeconds;

  const ExerciseEntity({
    required this.id,
    required this.name,
    this.instructions,
    this.sets = 0,
    this.reps = 0,
    required this.duration,
    this.restSeconds = 45,
  });

  ExerciseEntity copyWith({
    String? id,
    String? name,
    String? instructions,
    int? sets,
    int? reps,
    Duration? duration,
    int? restSeconds,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      instructions: instructions ?? this.instructions,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}
