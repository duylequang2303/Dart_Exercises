import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<ProfileEntity?> getProfile(String uid, String email) {
    return dataSource.getProfile(uid, email);
  }

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> data) {
    return dataSource.updateProfile(uid, data);
  }

  @override
  Future<void> changePassword(String newPassword) {
    return dataSource.changePassword(newPassword);
  }
}
