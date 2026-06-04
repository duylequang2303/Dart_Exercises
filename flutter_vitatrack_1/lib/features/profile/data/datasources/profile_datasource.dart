import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vitatrack_1/core/services/firestore_service.dart';
import 'package:flutter_vitatrack_1/features/profile/domain/entities/profile_entity.dart';

class ProfileDataSource {
  final FirestoreService _firestoreService;

  ProfileDataSource(this._firestoreService);

  Future<ProfileEntity?> getProfile(String uid, String email) async {
    final data = await _firestoreService.getDocument('users/$uid/profile', 'info');
    if (data == null) return null;
    return ProfileEntity.fromMap(uid, email, data);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestoreService.updateDocument('users/$uid/profile', 'info', data);
  }

  Future<void> changePassword(String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');
    await user.updatePassword(newPassword);
  }
}

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ProfileDataSource(firestoreService);
});
