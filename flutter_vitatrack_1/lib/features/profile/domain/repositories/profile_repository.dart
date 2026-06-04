import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String uid, String email);
  Future<void> updateProfile(String uid, Map<String, dynamic> data);
  Future<void> changePassword(String newPassword);
}
