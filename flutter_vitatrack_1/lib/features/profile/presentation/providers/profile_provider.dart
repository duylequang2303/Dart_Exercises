import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_vitatrack_1/features/profile/data/datasources/profile_datasource.dart';
import 'package:flutter_vitatrack_1/features/profile/domain/entities/profile_entity.dart';

class ProfileState {
  final ProfileEntity? profile;
  final bool dangTai;
  final String? loi;
  final bool daLuu;

  const ProfileState({
    this.profile,
    this.dangTai = false,
    this.loi,
    this.daLuu = false,
  });

  ProfileState copyWith({
    ProfileEntity? profile,
    bool? dangTai,
    String? loi,
    bool? daLuu,
    bool xoaLoi = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      dangTai: dangTai ?? this.dangTai,
      loi: xoaLoi ? null : loi ?? this.loi,
      daLuu: daLuu ?? this.daLuu,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileDataSource _dataSource;
  final UserEntity? _user;
  final Ref _ref;

  ProfileNotifier(this._dataSource, this._user, this._ref) : super(const ProfileState()) {
    if (_user != null) {
      load();
    }
  }

  Future<void> load() async {
    if (_user == null) return;
    state = state.copyWith(dangTai: true, xoaLoi: true, daLuu: false);
    try {
      final profile = await _dataSource.getProfile(_user.uid, _user.email);
      if (profile == null) {
        // Create an empty profile if none exists using auth info
        state = state.copyWith(
          dangTai: false,
          profile: ProfileEntity(uid: _user.uid, email: _user.email, ten: _user.tenHienThi),
        );
      } else {
        state = state.copyWith(dangTai: false, profile: profile);
      }
    } catch (e) {
      state = state.copyWith(dangTai: false, loi: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    state = state.copyWith(dangTai: true, xoaLoi: true, daLuu: false);
    try {
      await _dataSource.updateProfile(_user.uid, data);
      state = state.copyWith(daLuu: true);
      await load(); // Reload to get updated data
    } catch (e) {
      state = state.copyWith(dangTai: false, loi: e.toString());
    }
  }

  Future<void> dangXuat() async {
    await _ref.read(authProvider.notifier).dangXuat();
  }

  Future<void> doiMatKhau(String matKhauMoi) async {
    state = state.copyWith(dangTai: true, xoaLoi: true, daLuu: false);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Người dùng chưa đăng nhập');
      await user.updatePassword(matKhauMoi);
      state = state.copyWith(dangTai: false, daLuu: true);
    } on FirebaseAuthException catch (e) {
      String loiTV = 'Lỗi đổi mật khẩu';
      if (e.code == 'weak-password') {
        loiTV = 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      } else if (e.code == 'requires-recent-login') {
        loiTV = 'Vui lòng đăng nhập lại trước khi đổi mật khẩu';
      }
      state = state.copyWith(dangTai: false, loi: loiTV);
    } catch (e) {
      state = state.copyWith(dangTai: false, loi: 'Có lỗi xảy ra: $e');
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final dataSource = ref.watch(profileDataSourceProvider);
  final user = ref.watch(nguoiDungHienTaiProvider);
  return ProfileNotifier(dataSource, user, ref);
});
