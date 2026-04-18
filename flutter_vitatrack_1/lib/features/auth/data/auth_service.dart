import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vitatrack_1/features/auth/data/models/user_model.dart';
import 'package:flutter_vitatrack_1/features/auth/domain/entities/user_entity.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserEntity?> get luongNguoiDung {
    return _auth.authStateChanges().map((user) =>
        user != null ? UserModel.fromFirebaseUser(user) : null);
  }

  UserEntity? get nguoiDungHienTai {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  Future<UserEntity?> dangNhapEmail(String email, String matKhau) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: matKhau,
      );
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email không tồn tại');
        case 'wrong-password':
          throw Exception('Mật khẩu không đúng');
        case 'invalid-credential':
          throw Exception('Email hoặc mật khẩu không đúng');
        default:
          throw Exception('Đăng nhập thất bại: ${e.message}');
      }
    }
  }

  Future<UserEntity?> dangKyEmail(
      String email, String matKhau, String tenHienThi) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: matKhau,
      );
      await result.user!.updateDisplayName(tenHienThi);
      return UserModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email đã được sử dụng');
        case 'weak-password':
          throw Exception('Mật khẩu quá yếu (tối thiểu 6 ký tự)');
        default:
          throw Exception('Đăng ký thất bại: ${e.message}');
      }
    }
  }

  Future<void> dangXuat() async {
    await _auth.signOut();
  }
}