import 'package:flutter_vitatrack_1/features/workout/domain/entities/activity_entity.dart';
import 'package:flutter_vitatrack_1/features/workout/domain/repositories/workout_repository.dart';

class SearchExercises {
  final WorkoutRepository repository;

  SearchExercises({required this.repository});

  Future<List<ActivityEntity>> execute({String query = '', int? muscleId}) async {
    return await repository.searchExercises(query: query, muscleId: muscleId);
  }
}
