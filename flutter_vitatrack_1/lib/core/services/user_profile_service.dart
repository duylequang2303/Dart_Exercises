import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_service.dart';

class UserProfileService {
  final FirestoreService _firestoreService;

  UserProfileService(this._firestoreService);

  Future<void> saveOnboardingData(String uid, Map<String, dynamic> data) async {
    final collectionPath = 'users/$uid/profile';
    data['onboardingDone'] = true;
    await _firestoreService.setDocument(collectionPath, 'info', data);
  }
}

final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return UserProfileService(firestoreService);
});
