// lib/features/workout/domain/usecases/track_workout_progress.dart
import '../repositories/workout_repository.dart';

class TrackWorkoutProgress {
  final WorkoutRepository repository;

  TrackWorkoutProgress({required this.repository});

  Future<void> execute(Duration duration, Duration targetDuration) async {
    // Chuyển đổi tỉ lệ Duration hiện tại / Mục tiêu thành kiểu double
    double progress = 0.0;
    if (targetDuration.inSeconds > 0) {
      progress = duration.inSeconds / targetDuration.inSeconds;
    }
    
    // Truyền giá trị double vào đúng tham số đầu vào
    await repository.updateProgress(progress);
  }
}