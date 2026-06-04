import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_vitatrack_1/features/profile/data/datasources/profile_datasource.dart';
import 'package:flutter_vitatrack_1/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_vitatrack_1/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_vitatrack_1/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_vitatrack_1/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_vitatrack_1/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_vitatrack_1/features/profile/domain/usecases/change_password_usecase.dart';

// --- DEPENDENCY INJECTION ---
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final ds = ref.watch(profileDataSourceProvider);
  return ProfileRepositoryImpl(ds);
});

final getProfileUseCaseProvider = Provider((ref) => GetProfileUseCase(ref.watch(profileRepositoryProvider)));
final updateProfileUseCaseProvider = Provider((ref) => UpdateProfileUseCase(ref.watch(profileRepositoryProvider)));
final changePasswordUseCaseProvider = Provider((ref) => ChangePasswordUseCase(ref.watch(profileRepositoryProvider)));
// ----------------------------

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
  final UserEntity? _user;
  final Ref _ref;
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final ChangePasswordUseCase _changePassword;

  ProfileNotifier(
    this._user, 
    this._ref,
    this._getProfile,
    this._updateProfile,
    this._changePassword,
  ) : super(const ProfileState()) {
    if (_user != null) {
      load();
    }
  }

  Future<void> load() async {
    if (_user == null) return;
    state = state.copyWith(dangTai: true, xoaLoi: true, daLuu: false);
    try {
      final profile = await _getProfile(_user.uid, _user.email);
      if (profile == null) {
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
      await _updateProfile(_user.uid, data);
      state = state.copyWith(daLuu: true);
      await load(); 
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
      await _changePassword(matKhauMoi);
      state = state.copyWith(dangTai: false, daLuu: true);
    } catch (e) {
      String loiTV = 'Lỗi đổi mật khẩu';
      final errorStr = e.toString();
      if (errorStr.contains('weak-password')) {
        loiTV = 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      } else if (errorStr.contains('requires-recent-login')) {
        loiTV = 'Vui lòng đăng nhập lại trước khi đổi mật khẩu';
      } else {
        loiTV = 'Có lỗi xảy ra: $e';
      }
      state = state.copyWith(dangTai: false, loi: loiTV);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final user = ref.watch(nguoiDungHienTaiProvider);
  return ProfileNotifier(
    user, 
    ref,
    ref.watch(getProfileUseCaseProvider),
    ref.watch(updateProfileUseCaseProvider),
    ref.watch(changePasswordUseCaseProvider),
  );
});
