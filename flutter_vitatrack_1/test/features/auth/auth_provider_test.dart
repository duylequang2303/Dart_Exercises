import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vitatrack_1/features/auth/data/auth_service.dart';
import 'package:flutter_vitatrack_1/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_vitatrack_1/features/auth/presentation/providers/auth_provider.dart';

class FakeAuthService implements AuthService {
  final _controller = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  @override
  Stream<UserEntity?> get luongNguoiDung => _controller.stream;

  @override
  UserEntity? get nguoiDungHienTai => _currentUser;

  @override
  Future<UserEntity?> dangNhapEmail(String email, String matKhau) async {
    if (email == 'error@test.com') {
      throw Exception('Email không tồn tại');
    }
    _currentUser = UserEntity(
      uid: '123',
      email: email,
      tenHienThi: 'Test User',
      ngayTao: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<UserEntity?> dangKyEmail(String email, String matKhau, String tenHienThi) async {
    _currentUser = UserEntity(
      uid: '123',
      email: email,
      tenHienThi: tenHienThi,
      ngayTao: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> dangXuat() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> quenMatKhau(String email) async {
    if (email == 'invalid@test.com') {
      throw Exception('Email không hợp lệ');
    }
  }

  @override
  Future<bool> daHoanThanhOnboarding(String uid) async {
    return true;
  }

  @override
  Future<void> deleteAccount(String uid) async {
    _currentUser = null;
    _controller.add(null);
  }

  void close() {
    _controller.close();
  }
}

void main() {
  late FakeAuthService fakeAuthService;
  late ProviderContainer container;

  setUp(() {
    fakeAuthService = FakeAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuthService),
      ],
    );
  });

  tearDown(() {
    fakeAuthService.close();
    container.dispose();
  });

  test('Khởi tạo AuthNotifier với trạng thái đang tải', () {
    final state = container.read(authProvider);
    expect(state.dangTai, true);
    expect(state.nguoiDung, null);
  });

  test('Đăng nhập thành công cập nhật trạng thái người dùng', () async {
    // Để AuthNotifier khởi động và đăng ký stream
    await Future.delayed(Duration.zero);

    final notifier = container.read(authProvider.notifier);
    
    // Gọi đăng nhập
    final loginFuture = notifier.dangNhap('duy@gmail.com', '123456');
    
    // Kiểm tra trạng thái đang tải
    expect(container.read(authProvider).dangTai, true);

    await loginFuture;

    // Kiểm tra trạng thái hoàn tất
    final state = container.read(authProvider);
    expect(state.dangTai, false);
    expect(state.nguoiDung?.email, 'duy@gmail.com');
    expect(state.loi, null);
  });

  test('Đăng nhập thất bại trả về lỗi', () async {
    await Future.delayed(Duration.zero);
    final notifier = container.read(authProvider.notifier);

    await notifier.dangNhap('error@test.com', 'wrong');

    final state = container.read(authProvider);
    expect(state.dangTai, false);
    expect(state.nguoiDung, null);
    expect(state.loi, 'Email không tồn tại');
  });

  test('Đăng ký thành công tạo tài khoản mới', () async {
    await Future.delayed(Duration.zero);
    final notifier = container.read(authProvider.notifier);

    await notifier.dangKy('new@test.com', 'password', 'New User');

    final state = container.read(authProvider);
    expect(state.dangTai, false);
    expect(state.nguoiDung?.email, 'new@test.com');
    expect(state.nguoiDung?.tenHienThi, 'New User');
  });

  test('Quên mật khẩu thành công hiển thị thông báo', () async {
    await Future.delayed(Duration.zero);
    final notifier = container.read(authProvider.notifier);

    await notifier.quenMatKhau('duy@gmail.com');

    final state = container.read(authProvider);
    expect(state.thongBao, 'Email đặt lại mật khẩu đã được gửi');
    expect(state.loi, null);
  });

  test('Quên mật khẩu thất bại hiển thị lỗi', () async {
    await Future.delayed(Duration.zero);
    final notifier = container.read(authProvider.notifier);

    await notifier.quenMatKhau('invalid@test.com');

    final state = container.read(authProvider);
    expect(state.thongBao, null);
    expect(state.loi, 'Email không hợp lệ');
  });

  test('Đăng xuất đưa trạng thái về mặc định', () async {
    await Future.delayed(Duration.zero);
    final notifier = container.read(authProvider.notifier);

    // Đăng nhập trước
    await notifier.dangNhap('duy@gmail.com', '123456');
    expect(container.read(authProvider).nguoiDung, isNotNull);

    // Đăng xuất
    await notifier.dangXuat();
    
    final state = container.read(authProvider);
    expect(state.nguoiDung, null);
    expect(state.dangTai, false);
  });
}
