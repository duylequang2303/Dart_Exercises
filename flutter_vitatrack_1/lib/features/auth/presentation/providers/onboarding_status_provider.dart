import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

final onboardingStatusProvider = FutureProvider.autoDispose.family<bool, String>((ref, uid) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.daHoanThanhOnboarding(uid);
});
