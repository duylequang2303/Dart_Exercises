import '../repositories/profile_repository.dart';

class ChangePasswordUseCase {
  final ProfileRepository repository;
  ChangePasswordUseCase(this.repository);

  Future<void> call(String newPassword) {
    return repository.changePassword(newPassword);
  }
}
