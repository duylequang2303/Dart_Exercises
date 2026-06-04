import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<void> call(String uid, Map<String, dynamic> data) {
    return repository.updateProfile(uid, data);
  }
}
