import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../screens/auth/login_screen.dart';
import '../../../../screens/onboarding/onboarding_screen.dart';
import '../../../../widgets/bottom_nav.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_status_provider.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.dangTai) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.nguoiDung == null) {
      return const LoginScreen();
    }

    final uid = authState.nguoiDung!.uid;
    final onboardingStatus = ref.watch(onboardingStatusProvider(uid));

    return onboardingStatus.when(
      data: (isDone) {
        if (isDone) {
          return const BottomNav();
        } else {
          return const OnboardingScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => const Scaffold(
        body: Center(
          child: Text('Đã có lỗi xảy ra khi kiểm tra dữ liệu.'),
        ),
      ),
    );
  }
}
