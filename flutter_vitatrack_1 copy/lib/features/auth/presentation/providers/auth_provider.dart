import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/auth/data/auth_service.dart';
import 'package:flutter_vitatrack_1/features/auth/domain/entities/user_entity.dart';

class AuthState {
  final UserEntity? nguoiDung;
  final bool dangTai;
  final String? loi;
  final String? thongBao;

  const AuthState({
    this.nguoiDung,
    this.dangTai = false,
    this.loi,
    this.thongBao,
  });

  AuthState copyWith({
    UserEntity? nguoiDung,
    bool? dangTai,
    String? loi,
    String? thongBao,
    bool xoaLoi = false,
    bool xoaThongBao = false,
    bool xoaNguoiDung = false,
  }) {
    return AuthState(
      nguoiDung: xoaNguoiDung ? null : nguoiDung ?? this.nguoiDung,
      dangTai: dangTai ?? this.dangTai,
      loi: xoaLoi ? null : loi ?? this.loi,
      thongBao: xoaThongBao ? null : thongBao ?? this.thongBao,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription<UserEntity?>? _sub;

  AuthNotifier(this._authService) : super(const AuthState(dangTai: true)) {
    khoiDong();
  }

  void khoiDong() {
    _sub = _authService.luongNguoiDung.listen((nguoiDung) {
      state = AuthState(nguoiDung: nguoiDung, dangTai: false);
    });
  }

  Future<void> dangNhap(String email, String matKhau) async {
    state = state.copyWith(dangTai: true, xoaLoi: true, xoaThongBao: true);
    try {
      await _authService.dangNhapEmail(email, matKhau);
    } catch (e) {
      state = state.copyWith(
        dangTai: false,
        loi: e.toString().replaceAll('Exception: ', ''),
        xoaNguoiDung: true,
      );
    }
  }

  Future<void> dangKy(String email, String matKhau, String ten) async {
    state = state.copyWith(dangTai: true, xoaLoi: true, xoaThongBao: true);
    try {
      await _authService.dangKyEmail(email, matKhau, ten);
    } catch (e) {
      state = state.copyWith(
        dangTai: false,
        loi: e.toString().replaceAll('Exception: ', ''),
        xoaNguoiDung: true,
      );
    }
  }

  Future<void> quenMatKhau(String email) async {
    state = state.copyWith(dangTai: true, xoaLoi: true, xoaThongBao: true);
    try {
      await _authService.quenMatKhau(email);
      state = state.copyWith(
        dangTai: false,
        thongBao: 'Email đặt lại mật khẩu đã được gửi',
      );
    } catch (e) {
      state = state.copyWith(
        dangTai: false,
        loi: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> dangXuat() async {
    await _authService.dangXuat();
    state = const AuthState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

final nguoiDungHienTaiProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).nguoiDung;
});