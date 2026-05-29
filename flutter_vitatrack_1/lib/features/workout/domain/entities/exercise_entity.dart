
/// Domain entity representing a single Exercise.
class ExerciseEntity {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final Duration duration; // expected duration for this exercise

  const ExerciseEntity({
    required this.id,
    required this.name,
    this.sets = 0,
    this.reps = 0,
    required this.duration,
  });

  ExerciseEntity copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    Duration? duration,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
    );
  }
}
